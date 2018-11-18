import JSON
export TaskManager, load_task_from_json

struct TaskManager
    task_file
    task_dict
    param_file
    param_dict
end

function TaskManager(name; root="./task")
    task_file = joinpath(root, name*".json")
    param_file = joinpath(root, "params.json")
    task_dict = JSON.parsefile(task_file)
    param_dict = JSON.parsefile(param_file)
    TaskManager(task_file, task_dict, param_file, param_dict)
end

function load_task_from_json(name; root="./task")
    t = TaskManager(name, root=root)
    d = _create_data_entry_from_task(t)
    fv, fr = _load_params_from_task(t)
    for i in fv
        set_value!(d, i[2], i[1])
    end
    (range_name, range_iter) =_create_range_iterator(fr)
    t, d, range_name, range_iter
end

function _create_data_entry_from_task(task::TaskManager)
    t = task.task_dict
    p = task.param_dict
    folder_entry = _namelist_from_task(t, "folder_")
    group_entry = _namelist_from_task(t, "group_")
    DataEntry(t["root"],p,folder_entry,group_entry)
end

function _namelist_from_task(t::Dict, id_str::String)
    entry = Array{Array{String,1},1}()
    i = 1
    while true
        name = id_str * string(i)
        if haskey(t, name) && (t[name]!=nothing)
            push!(entry, t[name])
        else
            break
        end
        i +=1
    end
    entry
end

function _load_params_from_task(task::TaskManager)
    t_values = task.task_dict["target_values"]
    fix_values = []
    ranges = []
    if t_values != nothing
        for (k,v) in t_values
            if isa(v, String)
                pv = eval(Meta.parse(v))
            else
                pv = v
            end
            if isa(pv, AbstractArray)
                push!(ranges, (k,pv))
            else
                push!(fix_values, (k,pv))
            end
        end
    end
    fix_values, ranges
end

function _create_range_iterator(range_values)
    range_name = [x[1] for x in range_values]
    range_iter=Iterators.product([x[2] for x in range_values]...)
    range_name, range_iter
end
