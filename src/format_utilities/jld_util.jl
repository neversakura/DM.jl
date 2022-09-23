function save_jld2(
    file_path::AbstractString,
    group_path::AbstractString,
    groups...,
)
    path, file = splitdir(file_path)
    mkpath(path)
    jldopen(file_path, "a+") do f
        for (n, v) in Iterators.partition(groups, 2)
            f[group_path * "/" * n] = v
        end
    end
end


function load_jld2(
    file_path::AbstractString,
    group_path::AbstractString,
    groups...,
)
    names = [group_path * "/" * i for i in groups]
    FileIO.load(file_path, names...)
end


function check_jld2(
    file_path::AbstractString,
    group_path::AbstractString,
    group_name,
)
    group = group_path * "/" * group_name
    res = jldopen(file_path, "r") do f
        haskey(f, group)
    end
end
