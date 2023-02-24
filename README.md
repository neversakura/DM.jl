# DM

Data management module for scientific computing based on [HDF5](https://github.com/JuliaIO/HDF5.jl), [JDL2](https://github.com/JuliaIO/JLD2.jl) and [CVS](https://github.com/JuliaData/CSV.jl).

## Quickstart Guide
First define the data entry:
```julia
root = "data"

fmt_str = Dict(
    "Alex" => "%.4f",
    "Bob" => "%.2f",
    "Eve" => "%s",
    "Sandy" => "%d",
    "Anna" => "%.2e"
)

folders = [["Alex", "Bob"], ["Eve", "Sandy"]]
groups = [["Anna"]]

entry = DataEntry("test", root, fmt_str, folders, groups)
```
Next define the values for each parameters:
```julia
values_1 = Dict(
    "Anna" => 412314,
    "Alex" => 0.0312341,
    "Bob" => 1.3,
    "Eve" => "potato",
    "Sandy" => 5
)

values_2 = Dict(
    "Alex"=>0.013,
    "Bob"=>2,
    "Eve"=>"apple",
    "Anna"=>9482,
    "Sandy"=>1
)

file_name_1 = "data1.jld2"
file_name_2 = "data2.jld2"

data_name_1 = "Aubrey"
data_name_2 = "Pumpkin"
```
Then we can save the true data to the location specified by the entry:
```julia
save(entry, values_1, file_name_1, data_name_1, cos.(range(0,2π,length=50)))
save(entry, values_2, file_name_2, data_name_2, sin.(range(0,2π,length=50)))
```
Or load an index table of all the current stored data: 
```julia
get_index(entry)
```
Or delete one particular data set:
```julia
delete(entry, values_1, file_name_1, data_name_1)
```