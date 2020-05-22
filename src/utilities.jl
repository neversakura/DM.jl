function _get_extension(file_name)
    ext = splitext(file_name)[end]
    if ext[1] != '.'
        error("Invalid file extension.")
    end
    ext = ext[2:end]
    ext = ext == "hdf5" ? "h5" : ext
    if !(ext in ["jld2", "csv", "h5"])
        error("File type $ext is not supported.")
    end
    ext
end

function _check_file(file_path)
    if !isfile(file_path)
        error("File: $file_path does not exist.")
    end
end


function _get_function(operation, ext)
    getfield(DM, Symbol(operation * ext))
end


function _get_file_group_path(d::DataEntry, v, file_name::String)
    folder_path = get_folder_path(d, v)
    joinpath(folder_path, file_name), get_group_path(d, v)
end
