module DM

using Format, FileIO, JLD2, HDF5, Reexport
using DocStringExtensions
import CSV
import JSON

include("config.jl")
include("data_entry.jl")
include("utilities.jl")
include("format_utilities/hdf5_util.jl")
include("format_utilities/jld_util.jl")
include("format_utilities/csv_util.jl")
include("file_operation.jl")

export DataEntry
export load_config_from_json, convert_recursive_array, parse_string_to_num
export activate_param_set, get_param_set
export save, load, check, load_file_array, delete, writeattr, readattr, read
@reexport using CSVFiles, DataFrames

end # end module
