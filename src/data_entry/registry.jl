function get_params(d::DataEntry)
    sort(cat(d.folder_entries..., d.group_entries..., dims=1))
end

function build_new_registry(d::DataEntry)
    params = get_params(d)
    DataFrame(vcat([x=>String[] for x in params], ["file"=>String[], "group"=>String[]]))
end

function register_entry(registry, d::DataEntry, vals, file_name, data_name)
    file_path = replace(get_folder_path(d, vals) * "/" * file_name, "\\"=>"/")
    group_path = get_group_path(d, vals) * "/" * data_name
    params_template = get_param_set()
    params = get_params(d)
    res_dict = Dict(vcat([Symbol(p)=>cfmt(params_template[p], vals[p]) for p in params], [:file=>file_path, :group=>group_path])...)
    push!(registry, res_dict)
end

function write_registry(registry, file)
    CSV.write(file, registry)
end

function load_registry(file)
    CSV.File(file, type=String) |> DataFrame
end

function load_registry(file, entry::DataEntry)
    try
        load_registry(file)
    catch
        @warn "No valid registery file found. Build a new registery."
        build_new_registry(entry)
    end
end

function query_registry(reg, vals)
    params_template = get_param_set()
    vals_str = Dict(Symbol(k)=>cfmt(params_template[k], v) for (k, v) in vals)
    vals_keys = collect(keys(vals_str))
    @from i in reg begin
        @where all((x)->getproperty(i, x)==vals_str[x], vals_keys)
        @select i
        @collect DataFrame
    end
end

function query_registry(reg, vals, condition)
    params_template = get_param_set()
    vals_str = Dict(Symbol(k)=>cfmt(params_template[k], v) for (k, v) in vals)
    vals_keys = collect(keys(vals_str))
    @from i in reg begin
        @where all((x)->getproperty(i, x)==vals_str[x], vals_keys) && condition(i)
        @select i
        @collect DataFrame
    end
end