function _get_extension(file_name)
    ext = splitext(file_name)[end][2:end]
    ext = ext == "hdf5" ? "h5" : ext
    !(ext in ["csv", "h5"]) && error("File type $ext is not supported.")
    ext
end

_check_file(file_path) = !isfile(file_path) && error("File: $file_path does not exist.")
_get_function(operation, ext) = getfield(DM, Symbol(operation * ext))

function convert_recursive_array(a)
    if eltype(a) <: AbstractArray
        data = [convert_recursive_array(x) for x in a]
        d = ndims(data[1]) + 1
        cat(data..., dims=d)
    else
        a
    end
end

"""
    parse_string_to_num(d)

Parse the strings in a dictionary `d` to numbers.
```
"""
function parse_string_to_num(d)
    res = []
    for (k, v) in d
        if isa(v, String)
            pv = eval(Meta.parse(v))
        else
            pv = v
        end
        push!(res, k => pv)
    end
    Dict(res...)
end