function walk_entry_file(d::DataEntry, file_name)
    res = match_entry_file(d, file_name)
    isempty(res) ? nothing : to_dataframe(res)
end

function walk_entry(d::DataEntry, file_name)
    res = match_entry_file(d, file_name)
    for (val_dict, file_path) in res
    end
end

function match_entry_file(d::DataEntry, file_name)
    res = []
    for (root, dirs, files) in walkdir(d.root)
        if !isempty(files)
            file_entries = splitpath(relpath(root, d.root))
            length(file_entries) != length(d.folder_entries) && break
            miss_match_flag = false
            split_entries = []
            for (file_entry, folder_entry) in zip(file_entries, d.folder_entries)
                split_entry = [split(x, "=") for x in split(file_entry, "_")]
                if !any((i) -> split_entry[i][1] in folder_entry, 1:length(split_entry))
                    miss_match_flag = true 
                    break
                end
                split_entries = vcat(split_entries, [x[1]=>x[2] for x in split_entry])
            end
            # split_entries = []
            # for i in 1:length(file_entries)
            #     split_entries = vcat(split_entries, [split(x, "=") for x in split(file_entries[i], "_")])
            # end
            val_dict = Dict{String, String}(split_entries)
            for f in files
                if f == file_name
                    push!(res, (val_dict, joinpath(root, f)))
                end
            end
        end
    end
    res
end

function to_dataframe(file_entries)
    entry_names = [x for x in keys(file_entries[1][1])]
    l = length(entry_names)
    res = [Vector{String}() for i in 1:l+1]
    for entry in file_entries
        for i in 1:l
            push!(res[i], entry[1][entry_names[i]])
        end
        push!(res[end], entry[2])
    end
    entry_symbols = [Symbol(x) for x in entry_names]
    entry_symbols = [entry_symbols; :file]
    DataFrame(res, entry_symbols)
end