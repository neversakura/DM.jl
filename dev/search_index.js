var documenterSearchIndex = {"docs": [

{
    "location": "#",
    "page": "HOME",
    "title": "HOME",
    "category": "page",
    "text": ""
},

{
    "location": "#DM.DataEntry",
    "page": "HOME",
    "title": "DM.DataEntry",
    "category": "type",
    "text": "Locator for a single data entry. Uniquely defined by a set of parameters and their corresponding formatting strings. The parameter sets are divided into folder and group hierarchy.\n\nFields\n\nroot – the root directory of the data entry.\nformat_dict     – the dictionary containing formattors of corresponding parameters.\nvalue_dict      – the dictionary containing valuess of corresponding parameters.\nfolder_entries  – the list of all parameters which define the file hierarchy of the data entry.\ngroup_entries   – the list of all parameters which define the group hierarchy of the data entry.\n\n\n\n\n\n"
},

{
    "location": "#DM.DataEntry-NTuple{4,Any}",
    "page": "HOME",
    "title": "DM.DataEntry",
    "category": "method",
    "text": "DataEntry(root, format_dict, folder_entries, group_entries)\n\nInitialize a DataEntry type with empty values. folder_entries and group_entries are lists of their respective hierarchies.\n\n\n\n\n\n"
},

{
    "location": "#DM.dm_save-Tuple{DataEntry,String,Vararg{Any,N} where N}",
    "page": "HOME",
    "title": "DM.dm_save",
    "category": "method",
    "text": "dm_save(d::DataEntry, file_name::String, groups...)\n\nSave data to entry point d with file name file_name. Data are specified by their data names and values.\n\n\n\n\n\n"
},

{
    "location": "#DM.load_task_from_json-Tuple{Any}",
    "page": "HOME",
    "title": "DM.load_task_from_json",
    "category": "method",
    "text": "load_task_from_json(name; root=\"./task\")\n\nLoad task from task configuration file.\n\n\n\n\n\n"
},

{
    "location": "#DM.set_value!-Tuple{DataEntry,Any,Any}",
    "page": "HOME",
    "title": "DM.set_value!",
    "category": "method",
    "text": "set_value!(data_entry, value, key)\n\nSet the value of given parameters in DataEntry type. key and value can be a single key-value pair, or tuples of corresponding pairs.\n\n\n\n\n\n"
},

{
    "location": "#HOME-1",
    "page": "HOME",
    "title": "HOME",
    "category": "section",
    "text": "Modules = [DM]\nPrivate = false"
},

]}
