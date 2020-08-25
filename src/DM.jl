module DM

using Format, FileIO, JLD2, HDF5, Reexport
using DocStringExtensions
import CSV
import JSON

include("params.jl")
include("data_entry.jl")
include("utilities.jl")
include("load_json.jl")
include("hdf5_util.jl")
include("jld_util.jl")
include("csv_util.jl")

export DataEntry
export load_config_from_json
export activate_param_set, get_param_set
export save, load, check, load_file_array, delete, writeattr, readattr, read
@reexport using CSVFiles, DataFrames

for op in (:check, :save, :load, :delete, :writeattr, :readattr)
    eval(quote
        function $op(d::DataEntry, v, file_name::String, groups...)
            folder_path = get_folder_path(d, v)
            file_path = joinpath(folder_path, file_name)
            ext = _get_extension(file_name)
            if isempty(groups) || ext == "csv"
                group_path = ""
            else
                group_path = get_group_path(d, v)
            end
            $op(file_path, group_path, ext, groups...)
        end
    end)
end

function check(file_path::AbstractString, group_path::AbstractString, ext, groups...)
    if isfile(file_path)
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
function save(file_path::AbstractString, group_path::AbstractString, ext, groups...)
    f = _get_function("save_", ext)
    f(file_path, group_path, groups...)
end

function load(file_path::AbstractString, group_path::AbstractString, ext, groups...)
    _check_file(file_path)
    f = _get_function("load_", ext)
    f(file_path, group_path, groups...)
end

function delete(
    file_path::AbstractString,
    group_path::AbstractString,
    ext,
    groups...,
)
    if isempty(groups)
        rm(file_path)
    elseif isfile(file_path)
        f = _get_function("delete_", ext)
        f(file_path, group_path, groups...)
    end
end

function load_file_array(d::DataEntry, v, file_name::String, groups...)
    r_str = Regex(file_name * "-(\\d+)\\.(.+)")
    folder_path = get_folder_path(d, v)
    f_list = readdir(folder_path)
    group_path = get_group_path(d, v)
    # names = [group_path * "/" * i for i in groups]
    res = []
    for f in f_list
        m = match(r_str, f)
        if m != nothing
            f_path = joinpath(folder_path, m.match)
            ext = _get_extension(m.match)
            push!(res, load(f_path, group_path, ext, groups...))
        end
    end
    res
end

function writeattr(file_path::AbstractString, group_path, ext, attr_name, attr_value)
    _check_file(file_path)
    f = _get_function("writeattr_", ext)
    f(file_path, group_path, attr_name, attr_value)
end

function writeattr(
    file_path::AbstractString,
    group_path,
    dataset::String,
    ext,
    attr_name,
    attr_value,
)
    _check_file(file_path)
    f = _get_function("writeattr_", ext)
    f(file_path, group_path, dataset, attr_name, attr_value)
end

function readattr(file_path::AbstractString, group_path, ext, attr_name)
    _check_file(file_path)
    f = _get_function("readattr_", ext)
    f(file_path, group_path, attr_name)
end

function readattr(
    file_path::AbstractString,
    group_path,
    dataset::String,
    ext,
    attr_name,
)
    _check_file(file_path)
    f = _get_function("readattr_", ext)
    f(file_path, group_path, dataset, attr_name)
end

end # end module
