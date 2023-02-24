for op in (:check, :load) 
    eval(quote
        function $op(d::DataEntry, v::AbstractDict, file_name::String, groups...)
            file_path, group_path, ext = processing_path(d, v, file_name)
            group_path = isempty(groups) ? "" : group_path
            $op(file_path, group_path, ext, groups...)
        end
    end)
end

for op in (:check, :load)
    eval(quote
        function $op(d::DataEntry, v::DataFrameRow)
            file_path, group_path, ext = processing_path(d, v) 
            $op(file_path, group_path, ext, v["data"])
        end
    end)
end

function save(d::DataEntry, v::AbstractDict, file_name::String, groups...)
    v = param_check(d, v)
    file_path, group_path , ext = processing_path(d, v, file_name)
    save(file_path, group_path, ext, groups...)
    data_names = [n for (n, v) in Iterators.partition(groups, 2)]
    add2_index(d, v, file_name, data_names)
end

# This function is only for save a `DataFrame` to a `CSV` file.
function save(d::DataEntry, v::AbstractDict, file_name::String,
    data::AbstractDataFrame)
    v = param_check(d, v)
    file_path, group_path , ext = processing_path(d, v, file_name)
    save(file_path, group_path, ext, data)
end

function delete(d::DataEntry, v::AbstractDict, file_name::String, groups...)
    v = param_check(d, v)
    file_path, group_path, ext = processing_path(d, v, file_name)
    delete(file_path, group_path, ext, groups...)
    if ext != "csv"
        if isempty(groups)
            del_file_from_index(d, file_name)
        else
            del_index(d, v, file_name, [g for g in groups])
        end
    end
end

function delete(d::DataEntry, v::AbstractDataFrame)
    for entry in eachrow(v)
        data_name = entry["data"]
        file_path, group_path, ext = processing_path(d, entry)
        delete(file_path, group_path, ext, data_name)
    end
    del_index(d, v)
end

function delete(d::DataEntry, v::DataFrameRow)
    data_name = v["data"]
    file_path, group_path, ext = processing_path(d, v)
    delete(file_path, group_path, ext, data_name)
    del_index(d, v)
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

function save(file_path::AbstractString, group_path::AbstractString,
    ext, data::AbstractDataFrame)
    f = _get_function("save_", ext)
    f(file_path, group_path, data)
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
    v = param_check(d, v)
    r_str = Regex(file_name * "-(\\d+)\\.(.+)")
    folder_path = get_folder_path(d, v)
    f_list = readdir(folder_path)
    group_path = get_group_path(d, v)
    # names = [group_path * "/" * i for i in groups]
    res = []
    for f in f_list
        m = match(r_str, f)
        if m !== nothing
            f_path = joinpath(folder_path, m.match)
            ext = _get_extension(m.match)
            push!(res, load(f_path, group_path, ext, groups...))
        end
    end
    res
end

function param_check(d::DataEntry, v::Dict)
    vt = truncate_params(d, v)
    all([approx(v[k],val) for (k,val) in vt]) ? nothing : @warn "One or more parameters are truncated according to schemas. Consider modifying the parameter values."
    vt
end

approx(a::Number, b::Number) = isapprox(a, b)
approx(a::String, b::String) = a == b

function processing_path(d::DataEntry, v::AbstractDict, file_name::String)
    folder_path = get_folder_path(d, v)
    file_path = joinpath(folder_path, file_name)
    ext = _get_extension(file_name)
    if ext == "csv"
        group_path = ""
        @warn "Group path is not supported for CSV file."
    else
        group_path = get_group_path(d, v)
    end
    file_path, group_path, ext
end

function processing_path(d::DataEntry, v::DataFrameRow)
    file_name = v["file"]
    folder_path = get_folder_path(d, v)
    file_path = joinpath(folder_path, file_name)
    ext = _get_extension(file_name)
    if ext == "csv"
        group_path = ""
        @warn "Group path is not supported for CSV file."
    else
        group_path = get_group_path(d, v)
    end
    file_path, group_path, ext
end