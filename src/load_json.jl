"""
    load_config_from_json(name) -> DataEntry, Tasks

Load task from task configuration file. Return a generator for all the `Task` defined in the "target_values" field of the configuration file.
"""
function load_config_from_json(name)
    t = JSON.parsefile(name)
    if haskey(t, "target_values") && t["target_values"]!=nothing
        target_value_pair = parse_target_values(t["target_values"])
    else
        target_value_pair = ()
    end
    f(x)=typeof(x[1])==String ? [x] : x
    if haskey(t, "folder") && (t["folder"]!=nothing) && (!isempty(t["folder"]))
        folder_path = f(t["folder"])
    else
        folder_path = ()
    end
    if haskey(t, "group") && (t["group"]!=nothing) && (!isempty(t["group"]))
        group_path = f(t["group"])
    else
        group_path = ()
    end
    DataEntry(t["root"], folder_path, group_path), create_task_list(target_value_pair...)
end

"""
    parse_target_values(t)

Parse a dictionary of parameter names and their corresponding values into a list of key-value pairs. The values can be given as excutable code string.

# Examples
```julia-repl
julia> parse_target_values(Dict("a"=>1,"b"=>2,"c"=>"range(0,stop=2)"))
3-element Array{Any,1}:
 "c" => 0:2
 "b" => 2
 "a" => 1
```
"""
function parse_target_values(t)
    res = []
    for (k,v) in t
        if isa(v, String)
            pv = eval(Meta.parse(v))
        else
            pv = v
        end
        push!(res, k=>pv)
    end
    res
end

"""
    create_task_list("name"=>value...)

Create a task list generator from `name` - `value` pairs. `value` can be an iterable objects.

# Examples
```julia-repl
julia> collect(create_task_list("a"=>1, "b"=>range(0,stop=2)))
3-element Array{Tuple{Pair{String,Int64},Pair{String,Int64}},1}:
 (:a => 1, :b => 0)
 (:a => 1, :b => 1)
 (:a => 1, :b => 2)
```
"""
function create_task_list(args...)
    res = []
    for item in args
        push!(res, (Symbol(item.first)=>x for x in item.second))
    end
    Iterators.product(res...)
end


partition(v, num) = collect(Iterators.partition(v, num))
