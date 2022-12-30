search_index_file(path) = searchdir(path, "index.jld2")

function read_index_file_name(path)
    idx_files = search_index_file(path)
    isempty(idx_files) ? nothing : joinpath(path, idx_files[1])
end

function load_index_file(path)
    filename = read_index_file_name(path)
    filename === nothing ? nothing : JLD2.load(filename)
end

function save_to_index_file(path, d::DataEntry)
    jldopen(joinpath(path, "index.jld2"), "a+") do file
        entry_group = JLD2.Group(file, d.name)
        entry_group["root"] = d.root
        entry_group["params"] = d.params
        entry_group["folders"] = d.folder_entries
        entry_group["groups"] = d.group_entries
    end
end

function check_name_index_file(path, d::DataEntry)
    jldopen(joinpath(path, "index.jld2"), "r") do file
        haskey(file, d.name)
    end
end

function load_from_index_file(path, name)
    file_path = joinpath(path, "index.jld2")
    (r, p, f, g) = JLD2.load(file_path, name * "/root", name * "/params", name * "/folders", name * "/groups")
    r = joinpath(path, r)
    DataEntry(name, r, p, f, g)
end

function readgroups(path)
    jldopen(joinpath(path, "index.jld2"), "r") do file
        keys(file)
    end
end

function delete_from_index_file(path, name)
    jldopen(joinpath(path, "index.jld2"), "r+") do file
        delete!(file, name)
    end
end

"""
    load_index(path)

Load all the entry names in the `index.jld2` file under `path`. Return the result as an array of strings.
"""
load_index(path) = read_index_strings(joinpath(path, "index.jld2"))

"""
    load_index(path, entry_names)

Load the entry information of `entry_name` from `index.jld2` file under `path`.
"""
function load_index(path, entry_name)
    load_from_index_file(path, entry_name)
end

"""
    read_index_strings(file)

Load the entry information from an index `file`. Return an array of all the entry names as strings. 
"""
function read_index_strings(file)
    jldopen(file, "r") do file
        res = []
        for k in keys(file)
            subgroups = iterate_index_groups(file[k])
            if isempty(subgroups)
                push!(res, [k])
            else
                push!(res, k * "/" .* subgroups)
            end
        end
        res |> Iterators.flatten |> collect
    end
end

function iterate_index_groups(G::JLD2.Group)
    if haskey(G, "root")
        return []
    else
        res = []
        for k in keys(G)
            klist = iterate_index_groups(G[k])
            if isempty(klist)
                push!(res, k)
            else
                for ksub in klist
                    push!(res, k * "/" * ksub)
                end
            end
        end
        return res
    end
end