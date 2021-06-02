global _current_param_set

ParamSet = Dict{String,String}

"""
    activate_param_set(d::Dict{String,String})

Activate the parameter set from a dictionary `d`.
"""
function activate_param_set(d::Dict{String,String})
    global _current_param_set = d
end

"""
    activate_param_set(d::String)

Activate the parameter set from a json file, whose path is given by `d`.
"""
function activate_param_set(d::String)
    global _current_param_set = JSON.parsefile(d)
end

"""
    activate_param_set(name=>formatter...)

Activate the parameter set with given `name` and `formatter` pairs.
"""
function activate_param_set(args...)
    global _current_param_set = ParamSet(args...)
end

"""
    get_param_set()

Return current active parameter set as a dictionary.
"""
function get_param_set()
    _current_param_set
end

"""
    load_config_from_json(name) -> DataEntry, Tasks

Load tasks from configuration file.
"""
function load_config_from_json(name)
    t = JSON.parsefile(name)
    if haskey(t, "default_values") && t["default_values"] != nothing
        default_vals = parse_string_to_num(t["default_values"])
    else
        default_vals = Dict()
    end
    f(x) = typeof(x[1]) == String ? [x] : x
    res = Dict{String,DataEntry}()
    for (k, v) in t["tasks"]
        if haskey(v, "folder") && (v["folder"] != nothing) && (!isempty(v["folder"]))
            folder_path = f(v["folder"])
        else
            folder_path = ()
        end
        if haskey(v, "group") && (v["group"] != nothing) && (!isempty(v["group"]))
            group_path = f(v["group"])
        else
            group_path = ()
        end
        root_path = haskey(v, "root") ? joinpath(t["root"], v["root"]) : t["root"]
        res[k] = DataEntry(root_path, folder_path, group_path)
    end
    res, default_vals
end
