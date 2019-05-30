global _current_param_set

ParamSet = Dict{String,String}

"""
    activate_param_set(d::Dict{String,String})

Activate the parameter set from a dictionary `d`.
"""
function activate_param_set(d::Dict{String,String})
    global _current_param_set = d
end

"""
    activate_param_set(d::String)

Activate the parameter set from a json file, whose path is given by `d`.
"""
function activate_param_set(d::String)
    global _current_param_set = JSON.parsefile(d)
end

"""
    activate_param_set(name=>formatter...)

Activate the parameter set with given `name` and `formatter` pairs.
"""
function activate_param_set(args...)
    global _current_param_set = ParamSet(args...)
end

"""
    get_param_set()

Return current active parameter set as a dictionary.
"""
function get_param_set()
    _current_param_set
end
