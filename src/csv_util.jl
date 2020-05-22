function save_csv(file_path::String, group_path, data; kwargs...)
    if group_path != ""
        @warn "Group path ignored when saving to .csv file."
    end
    path, file = splitdir(file_path)
    mkpath(path)
    CSV.write(file_path, data; kwargs...)
end


function load_csv(file_path::String, group_path; kwargs...)
    if group_path != ""
        @warn "Group path ignored when loading .csv file."
    end
    CSV.File(file_path; kwargs...) |> DataFrame
end
