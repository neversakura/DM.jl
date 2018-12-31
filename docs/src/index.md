# DM.jl

*A data management module for scientific computing with Julia.*

## General Concepts

DM.jl module is built around the concepts of `Parameter Set`, `Task` and `Data Entry`. A `Parameter Set` is defined as a set of parameter names with the corresponding formatters. It is set at the global scope of the module. Internally, it is implemented by a dictionary type with key-value pairs being parameter name and its formatter respectively. For example
```julia
  julia> activate_param_set("alpha"=>"%.2f", "beta"=>"%d")
```
sets the internal `_current_param_set` to a dictionary with two fields: `alpha` and `beta`. The value of each each fields are corresponding by C style [printf format strings](https://en.wikipedia.org/wiki/Printf_format_string). Current active parameter set can be obtained by
```julia
  julia> get_param_set()
  Dict{String,String} with 2 entries:
  "alpha" => "%.2f"
  "beta"  => "%d"
```

A `Task` of a `Parameter Set` is a specific set of values with respect to a subset of `Parameter Set`. It can be any iterable object whose elements are `(name => value)` pairs. For example, a tuple can specify a `Task`
```julia
  julia> ("alpha"=>0.1, "beta"=1)
```
The idea behind the design is that, a `Task` maps to a single point in the parameter space/subspace for any computational jobs, i.e. a simulation run. Any computational jobs under different `Task`s should be decoupled from each other so they can be simply embarrassed parallelized.

A `Data Entry` acts as a locator to a specific data set. Instead of implementing a complex database, this module tries to use the tree structure of file system and [Hierarchical Data Format (HDF)](https://www.hdfgroup.org/) to manage and locate the data. `Data Entry` itself is `Task` independent. It only construct the format string of both the file system path and group path from the `Parameter Set`. For example, let's assume the total `Parameter Set` has five parameters, described by the following json file
```json
{
  "alex": "%.2f",
  "bob": "%.2f",
  "eve": "%.2f",
  "sandy": "%.2f",
  "anna": "%.2f"
}
```
If we want to use `alex`, `bob` and `eve` to specify the file system path, and furthermore, to use `alex` and `bob` as parent node for `eve`, the file system path format string would look like
```julia
  "alex=%.2f_bob=%.2f/eve=%.2f"
```
If the file format supports group hierarchy, a group path format string can also be  specified with the rest of parameters
```julia
  "anna=%.2f_sandy=%.2f"
```
All in all, to construct a `Data Entry` object, one needs to specify
1. The root folder path.
2. The file system partition
3. The group partition

```julia
  julia> DataEntry("root", [["alex", "bob"], ["eve"]], ["sandy", "anna"])
```
The partitions of parameters are given by nested list of parameter names. The innermost lists will be sorted when constructing the `Data Entry` object. Together with a `Task`, a `Data Entry` provides unique file system and group path format strings for a single point/subspace of the total parameter space.
