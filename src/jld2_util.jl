"""
    save_jld2(d::DataEntry, file_name::String, groups...)

Save data to a jld2 file at entry point `d` with given `file_name`. Data are specified by their data names and values.
"""
function save_jld2(d::DataEntry, v, file_name::String, groups...)
    folder_path = get_folder_path(d, v)
    group_path = get_group_path(d, v)
    mkpath(folder_path)
    file = joinpath(folder_path,file_name)
    jldopen(file, "a+") do f
        for (n, v)  in Iterators.partition(groups, 2)
            try
                f[group_path*"/"*n] = v
            catch
                @warn "Data name: $(n) already exists. Data not saved."
            end
        end
    end
end

function save_jld2(file_path::String, groups...)
    path, file = splitdir(file_path)
    mkpath(path)
    jldopen(file_path, "a+") do f
        for (n, v)  in Iterators.partition(groups, 2)
            try
                f[n] = v
            catch
                @warn "Data name: $(n) already exists. Data not saved."
            end
        end
    end
end

"""
    load_jld2(d::DataEntry, v, file_name::String, groups...)

load data from a jld2 file at entry point `d` with given `file_name`. Multiple data sets can be loaded simultaneously.
"""
function load_jld2(d::DataEntry, v, file_name::String, groups...)
    folder_path = get_folder_path(d, v)
    file = joinpath(folder_path,file_name)
    group_path = get_group_path(d, v)
    names = [group_path*"/"*i for i in groups]
    FileIO.load(file, names...)
end
