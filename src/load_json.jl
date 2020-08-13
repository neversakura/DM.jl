"""
    load_config_from_json(name) -> DataEntry, Tasks

Load tasks from configuration file.
"""
function load_config_from_json(name)
    t = JSON.parsefile(name)
    if haskey(t, "default_values") && t["default_values"] != nothing
        default_vals = parse_default_values(t["default_values"])
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
        root_path = haskey(v, "root") ? v["root"] : t["root"]
        res[k] = DataEntry(root_path, folder_path, group_path)
    end
    res, default_vals
end

"""
    parse_default_values(t)

Parse the dault value given in configuration file.
```
"""
function parse_default_values(t)
    res = []
    for (k, v) in t
        if isa(v, String)
            pv = eval(Meta.parse(v))
        else
            pv = v
        end
        push!(res, k => pv)
    end
    Dict(res...)
end
