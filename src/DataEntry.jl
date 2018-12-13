using Format
using JLD2, FileIO
export DataEntry, set_value!
export dm_save, dm_load, dm_load_from_task, dm_check
export get_folder_path, get_group_path # export for testing

"""
Locator for a single data entry. Uniquely defined by a set of parameters and their corresponding formatting strings. The parameter sets are divided into folder and group hierarchy.

**Fields**
- `root` -- the root directory of the data entry.
- `format_dict`     -- the dictionary containing formattors of corresponding parameters.
- `value_dict`      -- the dictionary containing valuess of corresponding parameters.
- `folder_entries`  -- the list of all parameters which define the file hierarchy of the data entry.
- `group_entries`   -- the list of all parameters which define the group hierarchy of the data entry.
"""
struct DataEntry
    root::String
    format_dict::Dict{String,String}
    value_dict::Dict{String, Union{Number, String, Nothing}}
    folder_entries::Array{Array{String,1},1}
    group_entries::Array{Array{String,1},1}
end

"""
    DataEntry(root, format_dict, folder_entries, group_entries)

Initialize a DataEntry type with empty values. `folder_entries` and `group_entries` are lists of their respective hierarchies.
"""
function DataEntry(root, format_dict, folder_entries, group_entries)
    value_dict=Dict{String, Union{Number, String, Nothing}}()
    for folders in folder_entries
        for n in sort(folders)
            value_dict[n]=nothing
        end
    end
    for groups in group_entries
        for n in sort(groups)
            value_dict[n]=nothing
        end
    end
    DataEntry(root, format_dict, value_dict, folder_entries, group_entries)
end

"""
    set_value!(data_entry, value, key)

Set the value of given parameters in DataEntry type. `key` and `value` can be a single key-value pair, or tuples of corresponding pairs.
"""
function set_value!(data_entry::DataEntry, value, key)
    data_entry.value_dict[key]=value
end

function set_value!(data_entry::DataEntry, value, key::Array{String,1})
    for (k,v) in zip(key, value)
        data_entry.value_dict[k] = v
    end
end

"""
    print_params(format_dict, key)

Print out the string representation of parameter set given by `key`. `key` can be a list of parameter sets. In this case, function will return a list of string representations.
"""
function print_params(format_dict,value_dict,key::Array{String,1})
    res = ""
    for name in key
        if occursin("header",name)
            res = entry[name]["value"]*"_"*res
        else
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
    res[1:end]
end

function get_folder_path(d::DataEntry)
    joinpath(d.root, print_params(d.format_dict, d.value_dict, d.folder_entries))
end

function get_group_path(d::DataEntry)
    print_params(d.format_dict, d.value_dict, d.group_entries)
end

# ================ save function ===============
"""
    dm_save(d::DataEntry, file_name::String, groups...)

Save data to entry point `d` with file name `file_name`. Data are specified by their data names and values.
"""
function dm_save(d::DataEntry, file_name::String, groups...)
    folder_path = get_folder_path(d)
    group_path = get_group_path(d)
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

function dm_load(d::DataEntry, file_name::String, groups...)
    folder_path = get_folder_path(d)
    file = joinpath(folder_path,file_name)
    group_path = get_group_path(d)
    names = [group_path * i for i in groups]
    load(file, names...)
end

function dm_check(d::DataEntry, file_name::String, group_name::String)
    folder_path = get_folder_path(d)
    group_path = get_group_path(d)
    file = joinpath(folder_path,file_name)
    group = group_path * group_name
    sub_groups = split(group,"/")
    if !isfile(file)
        return false
    end
    res = true
    f = jldopen(file, "r")
    g = f
    for s in sub_groups
        if haskey(g, s)
            g = g[s]
        else
            res = false
            break
        end
    end
    close(f)
    res
end

function dm_load_from_task(d::DataEntry, task_name, file_name::String, groups...;task_root="./task")
    task_file = joinpath(task_root, task_name*".json")
    task_dict = JSON.parsefile(task_file)
    folder_entries = _namelist_from_task(task_dict, "folder_")
    group_entries = _namelist_from_task(task_dict, "group_")
    folder_path = joinpath(d.root, print_params(d.format_dict, d.value_dict, folder_entries))
    file = joinpath(folder_path,file_name)
    group_path = print_params(d.format_dict, d.value_dict, group_entries)
    names = [group_path * i for i in groups]
    load(file, names...)
end
