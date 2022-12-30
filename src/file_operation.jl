for op in (:check, :save, :load, :delete)
    eval(quote
        function $op(d::DataEntry, v, file_name::String, groups...)
            v = param_check(d, v)
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
    vt == v ? nothing : @warn "One or more parameters are truncated according to schemas. Consider modifying the parameter values."
    vt
end

function dm_save(d::DataEntry, v, file_name::String, groups...; force == false)
    save(d, v, file_name, groups...)
end