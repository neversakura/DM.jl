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
function get_folder_path(d::DataEntry, values::Dict)
    joinpath(d.root, print_params(get_param_set(), values, d.folder_entries))
end

function get_folder_path(d::DataEntry, values)
    v = Dict(values...)
    joinpath(d.root, print_params(get_param_set(), v, d.folder_entries))
end

"""
    get_group_path(d::DataEntry, values)

Print out the group path given data entry `d` and the corresponding `values`
"""
function get_group_path(d::DataEntry, values::Dict)
    print_params(get_param_set(), values, d.group_entries)
end

function get_group_path(d::DataEntry, values)
    v = Dict(values...)
    print_params(get_param_set(), v, d.group_entries)
end