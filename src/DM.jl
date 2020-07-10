module DM

using Format
using FileIO
using DocStringExtensions
import CSV
using JLD
using HDF5
import JSON
using Reexport

include("params.jl")
include("data_entry.jl")
include("utilities.jl")
include("load_json.jl")
include("hdf5_util.jl")
include("jld_util.jl")
include("csv_util.jl")


export load_config_from_json, partition
export DataEntry
export activate_param_set, get_param_set
export save, load, check, load_file_array, delete

@reexport using CSVFiles, DataFrames


for op in (:check, :save, :load, :delete)
    eval(quote
        function $op(d::DataEntry, v, file_name::String, groups...)
            file_path, group_path = _get_file_group_path(d, v, file_name)
            $op(file_path, group_path, groups...)
        end
    end)
end


function check(
    file_path::AbstractString,
    group_path::AbstractString,
    groups...,
)
    if isfile(file_path)
        ext = _get_extension(file_path)
        f = _get_function("check_", ext)
        all([f(file_path, group_path, group_name) for group_name in groups])
    else
        false
    end
end

"""
$(SIGNATURES)

Save data in `groups` in to file `file_path`.
"""
function save(file_path::AbstractString, group_path::AbstractString, groups...)
    ext = _get_extension(file_path)
    f = _get_function("save_", ext)
    f(file_path, group_path, groups...)
end


function load(file_path::AbstractString, group_path::AbstractString, groups...)
    _check_file(file_path)
    ext = _get_extension(file_path)
    f = _get_function("load_", ext)
    f(file_path, group_path, groups...)
end


function delete(
    file_path::AbstractString,
    group_path::AbstractString,
    groups...,
)
    _check_file(file_path)
    ext = _get_extension(file_path)
    f = _get_function("delete_", ext)
    f(file_path, group_path, groups...)
end


function load_file_array(d::DataEntry, v, file_name::String, groups...)
    r_str = Regex(file_name * "-(\\d+)\\.(.+)")
    folder_path = get_folder_path(d, v)
    f_list = readdir(folder_path)
    group_path = get_group_path(d, v)
    #names = [group_path * "/" * i for i in groups]
    res = []
    for f in f_list
        m = match(r_str, f)
        if m != nothing
            f_path = joinpath(folder_path, m.match)
            push!(res, load(f_path, group_path, groups...))
        end
    end
    res
end

end # end module
