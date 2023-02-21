"""
Locator for a single data entry, uniquely defined by parameter names partitioned into file system path and group path.

**Fields**
- `name` -- the name of the linked data entry.
- `root` -- the root directory of the data entry.
- `params` -- the parameter set used to locate the data entry.
- `folder_entries`  -- the ordered partition of parameters names which define the file system path of the data entry.
- `group_entries`   -- the ordered partition of parameters names which define the group path of the data entry.
"""
struct DataEntry
    name::String
    root::String
    params::Dict
    folder_entries::Vector{Vector{String}}
    group_entries::Vector{Vector{String}}
    DataEntry(n, r, p, f, g) = new(n, r, p, [sort(i) for i in f], [sort(i) for i in g])
end

get_params(d::DataEntry) = d.params |> keys |> collect
get_params_fmt(d::DataEntry) = d.params
get_root(d::DataEntry) = d.root
get_name(d::DataEntry) = d.name
check_index(d::DataEntry) = isfile(joinpath(d.root, "index_entry.jld2"))


"""
    print_params(format_dict, value_dict, key)

Print out the path of parameter set given by `key`. `format_dict` and `value_dict` are look-up tables for the parameter formatters and values respectively. `key` should be an valid partition of parameter names.
"""
function print_params(format_dict, value_dict, key::Array{String,1})
    res = ""
    for name in key
        if haskey(value_dict, name)
            value = value_dict[name]
        elseif haskey(value_dict, Symbol(name))
            value = value_dict[Symbol(name)]
        else
            throw(KeyError(name))
        end
        data_string = cfmt(format_dict[name], value)
        res = res * name * "=" * data_string * "_"
    end
    try
        chop(res, tail=1)
    catch
        ""
    end
end

function print_params(format_dict, value_dict, key::Array{Array{String,1},1})
    res = ""
    for i in key
        param_str = print_params(format_dict, value_dict, i)
        res = res * param_str * "/"
    end
    try
        chop(res, tail=1)
    catch
        ""
    end
end

"""
    get_folder_path(d::DataEntry, values)

Print out the file system path given data entry `d` and the corresponding `values`.
"""
function get_folder_path(d::DataEntry, values::Union{Dict, DataFrameRow})
    joinpath(d.root, print_params(d.params, values, d.folder_entries))
end

function get_folder_path(d::DataEntry, values)
    v = Dict(values...)
    joinpath(d.root, print_params(d.params, v, d.folder_entries))
end

"""
    get_group_path(d::DataEntry, values)

Print out the group path given data entry `d` and the corresponding `values`
"""
function get_group_path(d::DataEntry, values::Union{Dict, DataFrameRow})
    print_params(d.params, values, d.group_entries)
end

function get_group_path(d::DataEntry, values)
    v = Dict(values...)
    print_params(d.params, v, d.group_entries)
end

"""
    truncate_param_val(entry::DataEntry, name, value::AbstractFloat)

Truncate the floating point parameter `name` with `value` according to rule provided in `entry`.
"""
function truncate_param_val(entry::DataEntry, name::AbstractString, value::AbstractFloat)
    str = cfmt(entry.params[name], value)
    eval(Meta.parse(str))
end

truncate_param_val(::DataEntry, ::AbstractString, values::Integer) = values

truncate_param_val(::DataEntry, ::AbstractString, value::AbstractString) = value

"""
    truncate_params(entry::DataEntry, vals::Dict)

Truncate the parameter values given in `vals` according to rules defined in `entry`. The function will remove the values which do not appear in the parameter list of `entry`.
"""
function truncate_params(entry::DataEntry, vals::Dict)
    res = Dict{String,Any}()
    for (k, v) in vals
        if haskey(entry.params, k)
            res[k] = truncate_param_val(entry, k, v)
        end
    end
    res
end

# index file operatations for DataEntry
function set_index(d::DataEntry, val, file_name, data_name)
    mkpath(d.root)
    val = param_check(d, val)
    df = DataFrame([[v for v in val]; ["file" => file_name, "data" => data_name]])
    jldopen(joinpath(d.root, "index_entry.jld2"), "a+") do f
        f[d.name] = df
    end
end

function get_index(d::DataEntry)
    index_file = joinpath(d.root, "index_entry.jld2")
    try
        jldopen(index_file, "r") do f
            f[d.name]
        end
    catch
        throw(ArgumentError("No index file exists for this data entry."))
    end
end

"""
    del_index(d::DataEntry, val, file_name, data_name)

Delete the index with parameter values `val`, `file_name`
and `data_name` from the DataEntry `d`.
"""
function del_index(d::DataEntry, val, file_name, data_name)
    val = param_check(d, val)
    jldopen(joinpath(d.root, "index_entry.jld2"), "r+") do f
        dsub = query_data_frame_con(f[d.name], val, file_name, data_name)
        delete!(f, d.name)
        if !isempty(dsub)
            f[d.name] = dsub
        end
    end
end

"""
    del_index(d::DataEntry, subframe::AbstractDataFrame)

Delete the indices with parameters given in DataFrame `subframe` from the DataEntry `d`.
"""
function del_index(d::DataEntry, subframe::AbstractDataFrame)
    jldopen(joinpath(d.root, "index_entry.jld2"), "r+") do f
        dsub = antijoin(f[d.name], subframe, on=names(subframe))
        delete!(f, d.name)
        if !isempty(dsub)
            f[d.name] = dsub
        end
    end
end

function query_data_frame_con(df, vals, fn, dn::String)
    vals_str = Dict(Symbol(k)=>v for (k, v) in vals)
    vals_str[:file]=fn
    vals_str[:data]=dn
    vals_keys = collect(keys(vals_str))
    @from i in df begin
        @where any((x)->getproperty(i, x)!=vals_str[x], vals_keys)
        @select i
        @collect DataFrame
    end
end

function query_data_frame_con(df, vals, fn, dn::AbstractArray)
    vals_str = Dict(Symbol(k)=>v for (k, v) in vals)
    vals_str[:file]=fn
    vals_keys = collect(keys(vals_str))
    @from i in df begin
        @where any((x)->getproperty(i, x)!=vals_str[x], vals_keys) || !(getproperty(i, :data) ∈ dn)
        @select i
        @collect DataFrame
    end
end

function add2_index(d::DataEntry, val, file_name, data_name::String)
    mkpath(d.root)
    jldopen(joinpath(d.root, "index_entry.jld2"), "a+") do f
        if haskey(f, d.name)
            val = param_check(d, val)
            df = f[d.name]
            if isempty(subset(f[d.name], dataframe_compstr(val, file_name, data_name)...))
                push!(df, Dict([[Symbol(k) => v for (k, v) in val]; [:file => file_name, :data => data_name]]))
                delete!(f, d.name)
                f[d.name] = df
            else
                @warn "Index already exists."
            end
        else
            set_index(d, val, file_name, data_name)
        end
    end
end

function add2_index(d::DataEntry, val, file_name, data_name::AbstractArray)
    mkpath(d.root)
    jldopen(joinpath(d.root, "index_entry.jld2"), "a+") do f
        if haskey(f, d.name)
            val = param_check(d, val)
            df = f[d.name]
            dsub = subset(f[d.name], dataframe_compstr(val, file_name)...)
            if isempty(dsub)
                for data in data_name
                    push!(df, Dict([[Symbol(k) => v for (k, v) in val]; [:file => file_name, :data => data]]))
                end
            else
                existing_data =  dsub.data
                for data in data_name
                    if data ∈ existing_data
                        @warn "Index $data already exists."
                    else
                        push!(df, Dict([[Symbol(k) => v for (k, v) in val]; [:file => file_name, :data => data]]))
                    end
                end
            end
            delete!(f, d.name)
            f[d.name] = df
        else
            set_index(d, val, file_name, data_name)
        end
    end
end
