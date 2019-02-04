using Format
import FileIO.save, FileIO.load
import CSV
using JLD2
export DataEntry
@reexport using DataFrames

"""
Locator for a single data entry, uniquely defined by parameter names partitioned into file system path and group path.

**Fields**
- `root` -- the root directory of the data entry.
- `folder_entries`  -- the ordered partition of parameters names which define the file system path of the data entry.
- `group_entries`   -- the ordered partition of parameters names which define the group path of the data entry.
"""
struct DataEntry
    root::String
    folder_entries::Array{Array{String,1},1}
    group_entries::Array{Array{String,1},1}
    DataEntry(r, f, g) = new(r, [sort(i) for i in f], [sort(i) for i in g])
end


"""
    print_params(format_dict, value_dict, key)

Print out the path of parameter set given by `key`. `format_dict` and `value_dict` are look-up tables for  parameter formatters and values respectively. `key` should be an valid partition of parameter names.
"""
function print_params(format_dict,value_dict,key::Array{String,1})
    res = ""
    for name in key
        if haskey(value_dict, name)
            data_string = cfmt(format_dict[name], value_dict[name])
            res = res*name*"="*data_string*"_"
        end
    end
    res[1:end-1]
end

function print_params(format_dict,value_dict,key::Array{Array{String,1},1})
    res = ""
    for i in key
        param_str = print_params(format_dict, value_dict, i)
        res = res * param_str * "/"
    end
    res
end

"""
    get_folder_path(d::DataEntry, values)

Print out the file system path given data entry `d` and corresponding `values`.
"""
function get_folder_path(d::DataEntry, values::Dict)
    joinpath(d.root, print_params(get_param_set(), values, d.folder_entries))
end

function get_folder_path(d::DataEntry, values)
    v = Dict(values...)
    joinpath(d.root, print_params(get_param_set(), v, d.folder_entries))
end

"""
    get_group_path(d::DataEntry, values)

Print out the group path given data entry `d` and corresponding `values`
"""
function get_group_path(d::DataEntry, values::Dict)
    print_params(get_param_set(), values, d.group_entries)
end

function get_group_path(d::DataEntry, values)
    v = Dict(values...)
    print_params(get_param_set(), v, d.group_entries)
end

# ================ save function ===============
"""
    save_jld2(d::DataEntry, file_name::String, groups...)

Save data to a jld2 file at entry point `d` with given `file_name`. Data are specified by their data names and values.
"""
function save_jld2(d::DataEntry, v, file_name::String, groups...)
    folder_path = get_folder_path(d, v)
    group_path = get_group_path(d, v)
    mkpath(folder_path)
    file = joinpath(folder_path,file_name)
    jldopen(file, "a+") do f
        for (n, v)  in Iterators.partition(groups, 2)
            try
                f[group_path * n] = v
            catch
                @warn "Data name: $(n) already exists. Data not saved."
            end
        end
    end
end
# =============== load function ================

function load_jld2(d::DataEntry, v, file_name::String, groups...)
    folder_path = get_folder_path(d, v)
    file = joinpath(folder_path,file_name)
    group_path = get_group_path(d, v)
    names = [group_path * i for i in groups]
    load(file, names...)
end

function save_csv(d::DataEntry, v, file_name::String, data; kwargs...)
    folder_path = get_folder_path(d, v)
    mkpath(folder_path)
    file = joinpath(folder_path,file_name)
    CSV.write(file, data; kwargs...)
end

function load_csv(d::DataEntry, v, file_name::String; kwargs...)
    folder_path = get_folder_path(d, v)
    file = joinpath(folder_path,file_name)
    CSV.File(file; kwargs...) |> DataFrame
end
