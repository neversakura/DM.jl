function save_hdf(d::DataEntry, v, file_name::String, groups...)
    folder_path = get_folder_path(d, v)
    group_path = get_group_path(d, v)
    mkpath(folder_path)
    file = joinpath(folder_path,file_name)
    h5open(file, "cw") do f
        for (n, v) in Iterators.partition(groups, 2)
            if !exists(f, group_path*"/"*n)
                write(f, group_path*"/"*n, v)
            else
                @warn "Data name: $(n) already exists. Data not saved."
            end
        end
    end
end

function save_hdf(file_path::String, groups...)
    path, file = splitdir(file_path)
    mkpath(path)
    h5open(file_path, "cw") do f
        for (n, v) in Iterators.partition(groups, 2)
            if !exists(f, n)
                write(f, n, v)
            else
                @warn "Data name: $(n) already exists. Data not saved."
            end
        end
    end
end

function load_hdf(d::DataEntry, v, file_name::String, groups...)
    folder_path = get_folder_path(d, v)
    file = joinpath(folder_path,file_name)
    group_path = get_group_path(d, v)
    names = [group_path*"/"*i for i in groups]
    h5open(file, "r") do f
        if length(names) == 1
            res = read(f, names[1])
        else
            res = [read(f, n) for n in names]
        end
        res
    end
end

function delete_hdf(d::DataEntry, v, file_name::String, groups...)
    folder_path = get_folder_path(d, v)
    file = joinpath(folder_path,file_name)
    group_path = get_group_path(d, v)
    names = [group_path*"/"*i for i in groups]
    h5open(file, "r+") do f
        for n in names
            if exists(f, n)
                o_delete(f, n)
            end
        end
    end
end
