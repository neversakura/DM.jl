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
    jldopen(joinpath(path, "index.jld2"), "r") do file
        delete!(file, name)
    end
end
