function save_h5(
    file_path::AbstractString,
    group_path::AbstractString,
    groups...,
)
    path, file = splitdir(file_path)
    mkpath(path)
    h5open(file_path, "cw") do f
        for (n, v) in Iterators.partition(groups, 2)
            if !Base.haskey(f, group_path * "/" * n)
                write(f, group_path * "/" * n, v)
            else
                @warn "Data name: $(n) already exists. Data not saved."
            end
        end
    end
end


function load_h5(
    file_path::AbstractString,
    group_path::AbstractString,
    groups...,
)
    if isempty(groups)
        h5open(file_path, "r")
    else
        names = [group_path * "/" * i for i in groups]
        h5open(file_path, "r") do f
            if length(names) == 1
                res = read(f, names[1])
            else
                res = [read(f, n) for n in names]
            end
            res
        end
    end
end


function delete_h5(
    file_path::AbstractString,
    group_path::AbstractString,
    groups...,
)
    names = [group_path * "/" * i for i in groups]
    h5open(file_path, "r+") do f
        for n in names
            if Base.haskey(f, n)
                delete_object(f, n)
            end
        end
    end
end


function check_h5(
    file_path::AbstractString,
    group_path::AbstractString,
    group_name,
)
    group = group_path * "/" * group_name
    res = h5open(file_path, "r") do f
        Base.haskey(f, group)
    end
end

function writeattr(d::DataEntry, v, file_name::String, attrs_dict::Dict)
    folder_path = get_folder_path(d, v)
    file_path = joinpath(folder_path, file_name)
    ext = _get_extension(file_name)
    if !(ext == "h5")
        throw(ArgumentError("Only hdf5 format supports attributes."))
    end
    group_path = get_group_path(d, v)
    group_path = convert(String, group_path)
    mkpath(folder_path)
    h5open(file_path, "cw") do f
        for (k, v) in attrs_dict
            attributes(f[group_path])[k] = v
        end
    end
end

function writeattr(d::DataEntry, v, file_name::String, dataset, attrs_dict::Dict)
    folder_path = get_folder_path(d, v)
    file_path = joinpath(folder_path, file_name)
    ext = _get_extension(file_name)
    if !(ext == "h5")
        throw(ArgumentError("Only hdf5 format supports attributes."))
    end
    group_path = get_group_path(d, v)
    group_path = convert(String, group_path)
    mkpath(folder_path)
    h5open(file_path, "cw") do f
        for (k, v) in attrs_dict
            attributes(f[group_path][dataset])[k] = v
        end
    end
end

writeattr(d::DataEntry, v, file_name::String, attrs_key, attrs_val) = writeattr(d, v, file_name, Dict(attrs_key => attrs_val))
writeattr(d::DataEntry, v, file_name::String, dataset, attrs_key, attrs_val) = writeattr(d, v, file_name, dataset, Dict(attrs_key => attrs_val))

function readattr(d::DataEntry, v, file_name::String)
    folder_path = get_folder_path(d, v)
    file_path = joinpath(folder_path, file_name)
    _check_file(file_path)
    ext = _get_extension(file_name)
    if !(ext == "h5")
        throw(ArgumentError("Only hdf5 format supports attributes."))
    end
    group_path = get_group_path(d, v)
    group_path = convert(String, group_path)
    h5open(file_path, "r") do f
        Dict(k => read(attributes(f[group_path])[k]) for k in keys(attributes(f[group_path])))
    end
end

function readattr(d::DataEntry, v, file_name::String, dataset)
    folder_path = get_folder_path(d, v)
    file_path = joinpath(folder_path, file_name)
    _check_file(file_path)
    ext = _get_extension(file_name)
    if !(ext == "h5")
        throw(ArgumentError("Only hdf5 format supports attributes."))
    end
    group_path = get_group_path(d, v)
    group_path = convert(String, group_path)
    h5open(file_path, "r") do f
        Dict(k => read(attributes(f[group_path][dataset])[k]) for k in keys(attributes(f[group_path])))
    end
end

function readattr(d::DataEntry, v, file_name::String, attrs::Vector)
    folder_path = get_folder_path(d, v)
    file_path = joinpath(folder_path, file_name)
    _check_file(file_path)
    ext = _get_extension(file_name)
    if !(ext == "h5")
        throw(ArgumentError("Only hdf5 format supports attributes."))
    end
    group_path = get_group_path(d, v)
    group_path = convert(String, group_path)
    h5open(file_path, "r") do f
        Dict(k => read(attributes(f[group_path])[k]) for k in attrs)
    end
end

function readattr(d::DataEntry, v, file_name::String, dataset, attrs::Vector)
    folder_path = get_folder_path(d, v)
    file_path = joinpath(folder_path, file_name)
    _check_file(file_path)
    ext = _get_extension(file_name)
    if !(ext == "h5")
        throw(ArgumentError("Only hdf5 format supports attributes."))
    end
    group_path = get_group_path(d, v)
    group_path = convert(String, group_path)
    h5open(file_path, "r") do f
        Dict(k => read(attributes(f[group_path][dataset])[k]) for k in attrs)
    end
end