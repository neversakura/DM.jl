function save_csv(d::DataEntry, v, file_name::String, data; kwargs...)
    folder_path = get_folder_path(d, v)
    mkpath(folder_path)
    file = joinpath(folder_path,file_name)
    CSV.write(file, data; kwargs...)
end

function save_csv(file_path::String, data; kwargs...)
    path, file = splitdir(file_path)
    mkpath(path)
    CSV.write(file_path, data; kwargs...)
end

function load_csv(d::DataEntry, v, file_name::String; kwargs...)
    folder_path = get_folder_path(d, v)
    file = joinpath(folder_path,file_name)
    CSV.File(file; kwargs...) |> DataFrame
end

function load_csv(file_name::String; kwargs...)
    CSV.File(file; kwargs...) |> DataFrame
end
