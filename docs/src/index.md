# DM.jl

*A data management module for scientific computing with Julia.*

## General Concepts

`DM.jl` is a hierarchy-model database management system (DBMS) built upon [Hierarchical Data Format](https://www.hdfgroup.org/) (HDF). It combines the filesystem and HDF5 file into a single hierarchy structure. The path to a specific dataset is determined by a set of parameters and their corresponding values. Consider an example where we want to run some simulations with different choices of internal parameters `alpha` and `beta`. We can use two different paths, `./alpha=1.0_beta=2.0/data.h5` and `./alpha=1.0_beta=1.5/data.h5`, to store the simulation results for different `beta` values.

## Parameter Set
In the case of scientific computing, the values of parameters are often specified by (floating point) numbers. To use the corresponding string representation of those numbers, we need to first define the rules to convert them to strings. This is done by defining a `Parameter Set`, which contains all the parameter names and the corresponding formatters (template strings). For instance, the following code block
```julia
  julia> activate_param_set("alpha"=>"%.2f", "beta"=>"%d")
```
sets the internal `_current_param_set` to a dictionary with two fields: `alpha` and `beta`. The value of each field is a C style [printf format strings](https://en.wikipedia.org/wiki/Printf_format_string). The actual values of `alpha` and `beta` will be converted into strings based on those string templates. 

The `Parameter Set` is set at the global scope of the module. Current active parameter set can be obtained by
```julia
  julia> get_param_set()
  Dict{String,String} with 2 entries:
  "alpha" => "%.2f"
  "beta"  => "%d"
```

## Data Entry
Instead of implementing a complex database, this module tries to use the tree structure of file system and [Hierarchical Data Format (HDF)](https://www.hdfgroup.org/) to manage and locate the data. Assume the total `Parameter Set` has five parameters, described by the following `json` file
```json
{
  "alex": "%.2f",
  "bob": "%.2f",
  "eve": "%.2f",
  "sandy": "%.2f",
  "anna": "%.2f"
}
```
We may want to use `alex`, `bob` and `eve` to specify the file system path, and use `alex` and `bob` as parent node for `eve`. The filesystem path formatter should be
```julia
  "alex=%.2f_bob=%.2f/eve=%.2f"
```
We may also want to use the rest of parameters to specify the group path. So the group path formatter should be
```julia
  "anna=%.2f_sandy=%.2f"
```
With the above formatters, the location of the potential data set is completely determined once the values of all parameters are given. The partition of the parameters is stored in a `DataEntry` object which contains the following information:
1. The root folder path.
2. The file system partition
3. The group partition

The constructor of the `DataEntry` is
```julia
  julia> DataEntry("root", [["alex", "bob"], ["eve"]], ["sandy", "anna"])
```
The first argument is the root folder path. The second and third arguments correspond the file system/group partitions, which are given by nested list of parameter names. The innermost lists will be sorted when the `DataEntry` object is constructed.

## Public Documentation

```@autodocs
Modules = [DM]
Private = false
```
