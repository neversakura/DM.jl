var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "#DM.jl-1",
    "page": "Home",
    "title": "DM.jl",
    "category": "section",
    "text": "A data management module for scientific computing with Julia."
},

{
    "location": "#General-Concepts-1",
    "page": "Home",
    "title": "General Concepts",
    "category": "section",
    "text": "DM.jl module is built around the concepts of Parameter Set, Task and Data Entry. A Parameter Set is defined as a set of parameter names with the corresponding formatters. For example, if we want to run a simulation which depends on parameters alpha and beta and store the results for different alpha, beta values,  we\'d like to store the actual datasets to a location uniquely determined by the parameters\' names and values. In the case of scientific computing, where the value of parameters are often specified by (floating point) numbers, it is reasonable to use the string representation of those numbers to specify the location of the actual datasets. The following code block  julia> activate_param_set(\"alpha\"=>\"%.2f\", \"beta\"=>\"%d\")sets the internal _current_param_set to a dictionary with two fields: alpha and beta, the values of which are C style printf format strings. It is set at the global scope of the module. Current active parameter set can be obtained by  julia> get_param_set()\n  Dict{String,String} with 2 entries:\n  \"alpha\" => \"%.2f\"\n  \"beta\"  => \"%d\"A Task of a Parameter Set is a specific set of values with respect to a subset of Parameter Set. It can be any iterable object whose elements are (name => value) pairs. For example, a tuple can specify a Task  julia> (\"alpha\"=>0.1, \"beta\"=1)The idea behind the design is that, a Task maps to a single point in the parameter space/subspace for any computational jobs, i.e. one simulation run. Any computational jobs under different Tasks should be decoupled from each other so no race condition exists between them.A Data Entry acts as a locator to a specific data set. Instead of implementing a complex database, this module tries to use the tree structure of file system and Hierarchical Data Format (HDF) to manage and locate the data. Data Entry itself is Task independent. It only construct the format string of both the file system path and group path from the Parameter Set. To be more specific, let\'s assume the total Parameter Set has five parameters, described by the following json file{\n  \"alex\": \"%.2f\",\n  \"bob\": \"%.2f\",\n  \"eve\": \"%.2f\",\n  \"sandy\": \"%.2f\",\n  \"anna\": \"%.2f\"\n}After all, the actual data should be stored somewhere in the file system. If we want to use alex, bob and eve to specify the file system path, and furthermore, to use alex and bob as parent node for eve, the package automatically construct the file system path format string as  \"alex=%.2f_bob=%.2f/eve=%.2f\"If the file format supports group hierarchy, a group path format string can also be specified by the rest of parameters  \"anna=%.2f_sandy=%.2f\"With the format string, a location of potential data sets is completely determined once a Task is given. All in all, to construct a Data Entry object, one needs to specifyThe root folder path.\nThe file system partition\nThe group partitionThe syntax is  julia> DataEntry(\"root\", [[\"alex\", \"bob\"], [\"eve\"]], [\"sandy\", \"anna\"])The second and third arguments correspond the file system/group partitions, which are given by nested list of parameter names. The innermost lists will be sorted when constructing the Data Entry object."
},

{
    "location": "#DM.DataEntry",
    "page": "Home",
    "title": "DM.DataEntry",
    "category": "type",
    "text": "Locator for a single data entry, uniquely defined by parameter names partitioned into file system path and group path.\n\nFields\n\nroot – the root directory of the data entry.\nfolder_entries  – the ordered partition of parameters names which define the file system path of the data entry.\ngroup_entries   – the ordered partition of parameters names which define the group path of the data entry.\n\n\n\n\n\n"
},

{
    "location": "#DM.activate_param_set-Tuple",
    "page": "Home",
    "title": "DM.activate_param_set",
    "category": "method",
    "text": "activate_param_set(name=>formatter...)\n\nActivate the parameter set with given name and formatter pairs.\n\n\n\n\n\n"
},

{
    "location": "#DM.activate_param_set-Tuple{Dict{String,String}}",
    "page": "Home",
    "title": "DM.activate_param_set",
    "category": "method",
    "text": "activate_param_set(d::Dict{String,String})\n\nActivate the parameter set from a dictionary d.\n\n\n\n\n\n"
},

{
    "location": "#DM.activate_param_set-Tuple{String}",
    "page": "Home",
    "title": "DM.activate_param_set",
    "category": "method",
    "text": "activate_param_set(d::String)\n\nActivate the parameter set from a json file, whose path is given by d.\n\n\n\n\n\n"
},

{
    "location": "#DM.get_param_set-Tuple{}",
    "page": "Home",
    "title": "DM.get_param_set",
    "category": "method",
    "text": "get_param_set()\n\nReturn current active parameter set as a dictionary.\n\n\n\n\n\n"
},

{
    "location": "#DM.load_config_from_json-Tuple{Any}",
    "page": "Home",
    "title": "DM.load_config_from_json",
    "category": "method",
    "text": "load_config_from_json(name) -> DataEntry, Tasks\n\nLoad tasks from configuration file.\n\n\n\n\n\n"
},

{
    "location": "#DM.parse_string_to_num-Tuple{Any}",
    "page": "Home",
    "title": "DM.parse_string_to_num",
    "category": "method",
    "text": "parse_string_to_num(d)\n\nParse the strings in a dictionary d to numbers. ```\n\n\n\n\n\n"
},

{
    "location": "#DM.save-Tuple{AbstractString,AbstractString,Any,Vararg{Any,N} where N}",
    "page": "Home",
    "title": "DM.save",
    "category": "method",
    "text": "save(file_path, group_path, ext, groups)\n\n\nSave data in groups in to file file_path.\n\n\n\n\n\n"
},

{
    "location": "#Public-Documentation-1",
    "page": "Home",
    "title": "Public Documentation",
    "category": "section",
    "text": "Modules = [DM]\nPrivate = false"
},

]}
