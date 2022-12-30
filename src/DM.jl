module DM

using DataFrames: getproperty
using Format, FileIO, Reexport
using HDF5, DocStringExtensions, JLD2
import CSV, JSON

@reexport using CSVFiles, DataFrames, Query

include("utilities.jl")
include("data_entry/base.jl")
include("data_entry/iterate.jl")
include("data_entry/registry.jl")
include("format_utilities/hdf5_util.jl")
include("format_utilities/csv_util.jl")
include("format_utilities/jld_util.jl")
include("file_operation.jl")
include("index_file.jl")

export DataEntry
export convert_recursive_array, parse_string_to_num
export load_file_array, writeattr, readattr, read
export walk_entry_file
export save_to_index_file, load_from_index_file, get_root, get_params_fmt, get_name, readgroups, delete_from_index_file

# dev APIs

# new public APIs
# TODO: refractor the APIs above
export save, load, check, delete
export load_index, truncate_params

end # end module
