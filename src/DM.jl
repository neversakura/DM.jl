module DM

import JSON
using Reexport
include("DataEntry.jl")
include("TaskManager.jl")
export activate_param_set, get_param_set
export save, load, check, load_file_array, delete

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
    check(d::DataEntry, v, file_name::String, group_name::String)

Check whether a data group named `group_name` exists in a file named `file_name` at data entry `d`.
"""
function check(d::DataEntry, v, file_name::String, group_name::String)
    folder_path = get_folder_path(d, v)
    group_path = get_group_path(d, v)
    file = joinpath(folder_path,file_name)
    if !isfile(file)
        return false
    end
    if occursin(".jld2", file_name)
        group = group_path * "/" * group_name
        res = jldopen(file, "r") do f
            try
                haskey(f, group)
            catch
                false
            end
        end
        res
    elseif occursin(".h5", file_name)
        group = group_path * "/" * group_name
        res = h5open(file, "r") do f
            exists(f, group)
        end
    else
        error("Unsupported file format.")
    end
end

"""
    check(d::DataEntry, v, file_name::String)

Check whether `file_name` exists at data entry `d`.
"""
function check(d::DataEntry, v, file_name::String)
    folder_path = get_folder_path(d, v)
    file = joinpath(folder_path,file_name)
    isfile(file)
end

"""
    save(d::DataEntry, v, file_name::String, "group_name_1", "value_1"...)

Save data sets (`value_1`, `value_2` ...) in corresponding groups (`group_name_1`, `group_name_2`...) in file (`file_name`), whose location is specified by data entry `d` and corresponding values `v`.
"""
function save(d::DataEntry, v, file_name::String, groups...)
    if occursin(".jld2", file_name)
        save_jld2(d, v, file_name, groups...)
    elseif occursin(".csv", file_name)
        save_csv(d, v, file_name, groups...)
    elseif occursin(".h5", file_name)
        save_hdf(d, v, file_name, groups...)
    else
        error("Unsupported file format.")
    end
end

"""
    load(d::DataEntry, v, file_name::String, "group_name_1"...)

Save data sets from groups (`group_name_1`, `group_name_2`...) in file (`file_name`), whose location is specified by data entry `d` and corresponding values `v`.
"""
function load(d::DataEntry, v, file_name::String, groups...)
    if occursin(".jld2", file_name)
        load_jld2(d, v, file_name, groups...)
    elseif occursin(".csv", file_name)
        load_csv(d, v, file_name, groups...)
    elseif occursin(".h5", file_name)
        load_hdf(d, v, file_name, groups...)
    else
        error("Unsupported file format.")
    end
end

function load_file_array(d::DataEntry, v, file_name::String, groups...)
    r_str = Regex(file_name * "-(\\d+)\\.(.+)")
    folder_path = get_folder_path(d, v)
    f_list = readdir(folder_path)
    group_path = get_group_path(d, v)
    names = [group_path *"/"*i for i in groups]
    res = []
    for f in f_list
        m = match(r_str, f)
        if m!=nothing
            f_path = joinpath(folder_path, m.match)
            push!(res, load(f_path, names...))
        end
    end
    res
end

function delete(d::DataEntry, v, file_name::String, groups...)
    if occursin(".h5", file_name)
        delete_hdf(d, v, file_name, groups...)
    else
        @warn "Unsupported file format for delete operation"
    end
end

end # end module
