module DM

using DataFrames: getproperty
using Format, FileIO, Reexport
using HDF5, DocStringExtensions
import CSV, JSON

@reexport using CSVFiles, DataFrames, Query

include("config.jl")
include("utilities.jl")
include("data_entry/base.jl")
include("data_entry/iterate.jl")
include("data_entry/registry.jl")
include("format_utilities/hdf5_util.jl")
include("format_utilities/csv_util.jl")
include("file_operation.jl")

export DataEntry
export load_config_from_json, convert_recursive_array, parse_string_to_num
export activate_param_set, get_param_set
export save, load, check, load_file_array, delete, writeattr, readattr, read
export walk_entry_file
export load_registry, register_entry, write_registry, query_registry

end # end module
