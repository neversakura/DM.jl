# DM.jl

*A data management module for scientific computing with Julia.*

## General Concepts

`DM.jl` is a hierarchy-model database management system (DBMS) built upon [Hierarchical Data Format](https://www.hdfgroup.org/) (HDF). It combines the filesystem and HDF5 file into a single hierarchy structure. The path to a specific dataset is determined by a set of parameters and their corresponding values. Consider an example where we need to a simulation with different choices of internal parameters `alpha` and `beta`. We'd like to store the actual datasets to a location uniquely determined by the parameters' names (`alpha` and `beta`) and the corresponding values. For instance, `./alpha=1.0_beta=2.0/data.h5` and `./alpha=1.0_beta=1.5/data.h5` store the simulation results for different `beta` values.

## Parameter Set
In the case of scientific computing, the values of parameters are often specified by (floating point) numbers. To use the corresponding string representation of those numbers, we need to first define the rules to . A `Parameter Set` is defined as a set of parameter names with the corresponding formatters (template strings). The following code block
```julia
  julia> activate_param_set("alpha"=>"%.2f", "beta"=>"%d")
```
sets the internal `_current_param_set` to a dictionary with two fields: `alpha` and `beta`, the values of which are C style [printf format strings](https://en.wikipedia.org/wiki/Printf_format_string). It is set at the global scope of the module. Current active parameter set can be obtained by
```julia
  julia> get_param_set()
  Dict{String,String} with 2 entries:
  "alpha" => "%.2f"
  "beta"  => "%d"
```

## Data Entry
A `Data Entry` acts as a locator to a specific data set. Instead of implementing a complex database, this module tries to use the tree structure of file system and [Hierarchical Data Format (HDF)](https://www.hdfgroup.org/) to manage and locate the data. It only construct the format string of both the file system path and group path from the `Parameter Set`. To be more specific, let's assume the total `Parameter Set` has five parameters, described by the following `json` file
```json
{
  "alex": "%.2f",
  "bob": "%.2f",
  "eve": "%.2f",
  "sandy": "%.2f",
  "anna": "%.2f"
}
```
After all, the actual data should be stored somewhere in the file system. If we want to use `alex`, `bob` and `eve` to specify the file system path, and furthermore, to use `alex` and `bob` as parent node for `eve`, the package automatically construct the file system path format string as
```julia
  "alex=%.2f_bob=%.2f/eve=%.2f"
```
If the file format supports group hierarchy, a group path format string can also be specified by the rest of parameters
```julia
  "anna=%.2f_sandy=%.2f"
```
With the format string, a location of potential data sets is completely determined once a `Task` is given. All in all, to construct a `Data Entry` object, one needs to specify
1. The root folder path.
2. The file system partition
3. The group partition
The syntax is
```julia
  julia> DataEntry("root", [["alex", "bob"], ["eve"]], ["sandy", "anna"])
```
The second and third arguments correspond the file system/group partitions, which are given by nested list of parameter names. The innermost lists will be sorted when constructing the `Data Entry` object.

## Public Documentation

```@autodocs
Modules = [DM]
Private = false
```
