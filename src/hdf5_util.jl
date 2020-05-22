function save_h5(
    file_path::AbstractString,
    group_path::AbstractString,
    groups...,
)
    path, file = splitdir(file_path)
    mkpath(path)
    h5open(file_path, "cw") do f
        for (n, v) in Iterators.partition(groups, 2)
            if !exists(f, group_path * "/" * n)
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


function delete_h5(
    file_path::AbstractString,
    group_path::AbstractString,
    groups...,
)
    names = [group_path * "/" * i for i in groups]
    h5open(file_path, "r+") do f
        for n in names
            if exists(f, n)
                o_delete(f, n)
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
        exists(f, group)
    end
end
