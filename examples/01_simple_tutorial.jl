### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ dff15c77-a10d-4ed2-a55c-89945ccb8f81
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.add(url="https://github.com/neversakura/DM.jl", rev="master")
	Pkg.add("PlutoUI")
	Pkg.add("HypertextLiteral")
	using PlutoUI, HypertextLiteral, DM
end;

# ╔═╡ 73a054dd-bf8d-45ea-bf40-cd74f515c38a
md"""# Interactive tutorial for DM data entry

In this tutorial we will demonstrate how to create and manipulate a data entry in `DM.jl`.

"""

# ╔═╡ 2c4d4fae-7510-4b82-916c-c272eb033bb8
md"""## The data set entry

### Values of the data set

The first data set has five entries, `Alex`, `Bob`, `Eve`, `Sandy` and `Anna`. Let specify their values:
"""

# ╔═╡ 844da7f1-fbe2-4792-991e-2573e7b4d3ac
md"""

_`Alex` is struggling with a measurement with a small signal response $(@bind Alex Scrubbable(0.03123412, format=".5f"))._

_While `Anna` needs to deal with an astronomical number $(@bind Anna Scrubbable(412314, format=".2e"))._

_`Bob` is really on the average side $(@bind Bob Scrubbable(1.3, format=".2f"))._

_`Sandy` has $(@bind Sandy Scrubbable(1:10; default = 5)) apples to share with his groupmates._
"""

# ╔═╡ d4e9d58e-45c7-4159-8a5d-f7ecb76f351d
@bind Eve Select(["potato", "carrot", "apple"])

# ╔═╡ 61e41405-6d51-48df-bf5e-f9bdd56798f0
md"""
_`Eve` brings something $(Eve) to everyone._
"""

# ╔═╡ 4266c21c-1a80-4510-9132-7e0180edc09b
md"""
Now we put everything in a dictionary:
"""

# ╔═╡ 2ed805a0-da3a-4cf5-bf33-c83e8a751e13
values = Dict("Alex"=>Alex, "Bob"=>Bob, "Eve"=>Eve, "Anna"=>Anna, "Sandy"=>Sandy)

# ╔═╡ 4947d4ea-2aa2-4beb-86d3-edaaa9a8a185
md"""
### Formatting the values

Now it's time to specify a format string like ".2f" to be used to format the each value.
"""

# ╔═╡ e1e9fede-ed34-4dcd-9406-ee3fa73a208b
    fmt_str = Dict(
        "Alex" => "%.4f",
        "Bob" => "%.2f",
        "Eve" => "%s",
        "Sandy" => "%d",
        "Anna" => "%.2e"
    )

# ╔═╡ d088e43b-70e7-4b48-a9a8-f813135642b4
md"""

### Hierarchy struture of the data set

The exact data is store in a hierarchy structure of both the file system and the HDF5 style group structure. For example a particular data block could be inside a group `Anna=4.12e+05/` of a file called\
`test/Alex=0.0312_Bob=1.30/Eve=potato_Sandy=5/data.jld2`.


The file and group paths are determined by the parameters and their values. We need to decide which parameter goes into the file path and which parameter goes into the group path. 
"""

# ╔═╡ 54bd2a6f-e0da-4daa-8311-660e99781fb2
root = "test";

# ╔═╡ fd634b44-8bbe-45b1-af82-2df66523ba3d
md"""_The root folder for the data entry is "$(root)"._"""

# ╔═╡ 6b80b81a-9ff3-479c-a91d-028f59ec5676
md"""
Here we specify a file name and a name for the data block.
"""

# ╔═╡ 56c0ec4c-5d66-4392-b09f-4a1620e75ca4
@bind file_name Select(["data1.jld2", "data2.jld2", "data3.jld2"])

# ╔═╡ 31183b0e-1d6a-4c4b-aab0-33bb192a5d1c
@bind data_name Select(["sun", "lunna", "mars"])

# ╔═╡ c361b02d-39a2-460b-8ee3-15064a44831b
md"""Here we specify the parameters which are going into the file path."""

# ╔═╡ d19a8c9c-cb73-4359-a04c-3fdf29164f57
folders = [["Alex", "Bob"], ["Eve", "Sandy"]]

# ╔═╡ 84bce692-d6b4-4b63-8372-0338cd0d5203
md"""Here we specify the parameters which are going into the group path."""

# ╔═╡ ba64fd9a-28f0-4ba1-9cbc-5b810c064f51
groups = [["Anna"]]

# ╔═╡ 5d6d52ea-ac32-459a-b0cf-5dbf86067701
md"Finally we can create the DataEntry object."

# ╔═╡ 7e6a4f85-0621-4006-a349-45eb838f8a1c
entry = DataEntry("test", root, fmt_str, folders, groups)

# ╔═╡ f1b3d924-0be3-4c80-8acf-ebb884909e51
md"""

## Save the data to an entry

### Data block
A data block is the data we care about, i.e., a list of simulation results, a table of measurement outcomes.
"""

# ╔═╡ 338453b6-2f9a-4285-81d5-190267691bdc
data = cos.(range(0,2π,length=100))

# ╔═╡ ba8d0ce5-8b0b-42b3-b972-f9237a9286a0
@htl("""

<article class="learning">
	<h6>
		Click to save the data block
	</h6>
</article>


<style>

	article.learning {
		background: #f996a84f;
		padding: 1em;
		border-radius: 5px;
	}

	article.learning h6::before {
		content: "👇";
	}

	article.learning p::first-letter {
		font-size: 1.5em;
		font-family: cursive;
	}

</style>
""")

# ╔═╡ 18e10a61-75af-48bd-908c-70208d6107d3
@bind save_data Button("save")

# ╔═╡ 5ec1d645-6006-4bac-aab4-7571d56a55b8
let
	save_data
	try
		save(entry, values, file_name, data_name, data)
	catch ArgumentError
		@warn "data already exists"
	end
end

# ╔═╡ 1b0cfcad-8ac1-45ef-a9d5-4a931e0020b8
md"""Opps, we have an warning _One or more parameters are truncated according to schemas. Consider modifying the parameter values._ This is because the values we specified changed according to the format strings. We can avoid this warning by truncating the data values first using `truncate_params`.""" 

# ╔═╡ 6dc2da38-78d1-4f54-ab8f-58a3f7ee3a29
tValues = truncate_params(entry, values)

# ╔═╡ c5a5a12b-0f82-4cdf-8ecf-312700702d6e
md"""
### Index file

It is convenient to create an index file for each data entry for better searchability. So each time we save a data entry, it is better to update the corresponding information in an entry index file. This can be done using `set_index`.
"""

# ╔═╡ d52ad3fb-a05a-43f2-a428-f18e7396cb96
@htl("""

<article class="learning">
	<h6>
		Click to save the index
	</h6>
</article>


<style>

	article.learning {
		background: #f996a84f;
		padding: 1em;
		border-radius: 5px;
	}

	article.learning h6::before {
		content: "👇";
	}

	article.learning p::first-letter {
		font-size: 1.5em;
		font-family: cursive;
	}

</style>
""")

# ╔═╡ 6af6caf9-19c2-4a1a-8dc2-7c88e34d4f7e
@bind set_idx Button("set_index")

# ╔═╡ 4c5ad925-e262-4d94-a2c5-09d35acdf162
let
	set_idx
	try
		set_index(entry, tValues, file_name, data_name)
	catch ArgumentError
		@warn "An index entry already exists."
	end
end

# ╔═╡ 914fdb0a-cfe2-4e1a-820c-02c115234099
md"""We can read the index file using `get_index`."""

# ╔═╡ 0122acf5-048c-49b5-a565-8ba26a8c413f
try
	get_index(entry)
catch ArgumentError
	@warn "No such index exists."
end

# ╔═╡ eb5b9a2d-decd-4317-b2a2-02f114eb5fe9
md"""
## Load data from an entry

It is convenient to load the data block direct from the entry file if the original `DataEntry`, parameter values, file name and data name are available. The format strings essentially provide a hash map for all the parameters.
"""

# ╔═╡ 14b58a53-7e37-40aa-858a-79143742f42e
@htl("""

<article class="learning">
	<h6>
		Click to load the data block
	</h6>
</article>


<style>

	article.learning {
		background: #f996a84f;
		padding: 1em;
		border-radius: 5px;
	}

	article.learning h6::before {
		content: "👇";
	}

	article.learning p::first-letter {
		font-size: 1.5em;
		font-family: cursive;
	}

</style>
""")

# ╔═╡ c051efa2-4158-41db-abf0-fc0bb73fbf5b
@bind load_data Button("load")

# ╔═╡ 236fe77c-e0e2-469a-8e8b-39a0fdc5c341
let
	load_data
	try
		load(entry, tValues, file_name, data_name)
	catch
		@warn "The entry does not exist."
	end
end

# ╔═╡ 60e37fef-01f3-4dd2-a689-66dde3a6374b
md"""

An alternative way is to use one row from the index `DataFrame` as the locator of the data block. 
"""

# ╔═╡ ac4ae73a-6ffa-4c98-a83c-30ea1e919d2e
idx = get_index(entry)[1,:]

# ╔═╡ 74cf2052-93db-461f-b577-ab055561fa27
load(entry, idx)

# ╔═╡ ff7c6e52-ac41-4ee5-b1c7-c65ebe27cd72
md"""
## Delete the data and index

When deleting the data, please make sure to delete the index entry too.
"""

# ╔═╡ 77d96b23-ae46-4086-94cd-553924436ec4
@htl("""

<article class="learning">
	<h6>
		Delete both the data block and the index entry
	</h6>
</article>


<style>

	article.learning {
		background: #f996a84f;
		padding: 1em;
		border-radius: 5px;
	}

	article.learning h6::before {
		content: "👇";
	}

	article.learning p::first-letter {
		font-size: 1.5em;
		font-family: cursive;
	}

</style>
""")

# ╔═╡ 36e2ffc0-8ea3-4925-adf3-747d8574cb4b
@bind delete_data_index Button("delete")

# ╔═╡ 8e34ab6f-d6d8-46e2-af4e-8d65a42e7076
let
	delete_data_index

	delete(entry, tValues, file_name, data_name)
	del_index(entry, tValues, file_name, data_name)
end

# ╔═╡ 44a2dd9b-70d6-41dc-ac66-f2fdd8cec8ba
md"""Trying to delete them again will result in error."""

# ╔═╡ 39b3fcff-6d0a-48e9-af1c-fc963d2c8078
get_index(entry)

# ╔═╡ bb24d6cb-aaf0-42de-b0f1-c5a522ca8f0b
load(entry, tValues, file_name, data_name)

# ╔═╡ b0f01d8d-52a9-4a62-a5d7-974c93334e9e
md"""
## Multiple data values
"""

# ╔═╡ 894de4bd-d265-4346-acb4-0c52a180563b
tValues

# ╔═╡ 03ab549d-b7b8-43ad-87f5-e6d23b448304
md"We define a second data block in the following cell."

# ╔═╡ 57147368-ca07-44b7-9402-dcdc901e915e
begin
	values2 = Dict("Alex"=>0.013, "Bob"=>2, "Eve"=>"apple", "Anna"=>9482, "Sandy"=>1)
	tValues2 = truncate_params(entry, values2)
	file_name2 = file_name
	data_name2 = "Pumpkin"
end;

# ╔═╡ 6c4eed79-7480-4644-9193-d93f093395d2
md"First we resave the first data block again. It is a better practice to save both the data block and the index entry at the same time."

# ╔═╡ a3e7cac8-e371-4ea3-814e-ff4b94b6ba49
begin
	save(entry, tValues, file_name, data_name, data)
	add2_index(entry, tValues, file_name, data_name)
end

# ╔═╡ de6ad70a-62e9-4e1b-bd14-5d5355f2f9cd
get_index(entry)

# ╔═╡ 8fa21201-6538-4ce6-9b48-54340d4731a9
begin
	save(entry, tValues2, file_name2, data_name2, sin.(range(0,2π,length=50)))
	add2_index(entry, tValues2, file_name2, data_name2)
end

# ╔═╡ 26d6c81f-5fbd-4042-ac5b-fba06fb823af
md"""
Now we have two data blocks in the same data set. Next we review the operations introduced in this tutorial.

### Load
"""

# ╔═╡ 80b29892-8c50-475a-9b08-d46864a2ef67
load(entry, tValues, file_name, data_name)

# ╔═╡ ba89c224-828e-4f92-9f9d-1f848277355f
load(entry, tValues2, file_name2, data_name2)

# ╔═╡ cc527e49-af3d-4caf-b828-707ba8fc2890
idx2 = get_index(entry)

# ╔═╡ e36e29bb-8b72-4646-bf0a-57b5307d240f
@bind load_n Select([1, 2])

# ╔═╡ 216e55a0-5e9b-4cd7-b39a-eb32d1f09be4
load(entry, idx2[load_n, :])

# ╔═╡ df9caf3f-2af6-43b6-b7aa-ab9cef8a3f1b
md"### Delete"

# ╔═╡ 901085ab-96c4-4228-b00f-df8611931f3f
begin
	delete(entry, idx2[1, :])
	del_index(entry, tValues, file_name, data_name)
end

# ╔═╡ 3189c25a-4443-421a-8926-2090eadd80f3
entry |> get_index

# ╔═╡ 006c019e-a8e4-4697-a9b5-fd65794706c0
load(entry, tValues, file_name, data_name)

# ╔═╡ cd4ff274-943e-4b36-8c2c-a1bd8de74923
load(entry, tValues2, file_name2, data_name2)

# ╔═╡ 37aea785-ab84-4fcd-bf1a-19eb27b0e152
begin
	delete(entry, tValues2, file_name2, data_name2)
	del_index(entry, tValues2, file_name2, data_name2)
end

# ╔═╡ 30a90598-6539-4dc8-9fdd-7af5faa11dea
md"""

## Index for all entries

Finally, we mention that, in addition to the index files of each entry, there is an overall index file for the entire data base. It is used to store every data set configuration so you don't have to recreate the `DataEntry` object each time.
"""

# ╔═╡ 3041ccb3-1acd-4bb1-b5b4-8a444cf8b01a
try
	save_to_index_file("test", entry)
catch
	@warn "Entry already saved."
end;

# ╔═╡ dbbc6f23-fa5e-4b6d-942a-d90a5e25b0a3
load_entry("test")

# ╔═╡ 9529048e-55c1-48e9-9808-d5f9c840c985
load_entry("test", "test")

# ╔═╡ 30183ec3-b4ae-4c3e-9a1a-1a98dcc9a5f2
delete_entry("test", "test")

# ╔═╡ Cell order:
# ╠═dff15c77-a10d-4ed2-a55c-89945ccb8f81
# ╟─73a054dd-bf8d-45ea-bf40-cd74f515c38a
# ╟─2c4d4fae-7510-4b82-916c-c272eb033bb8
# ╟─844da7f1-fbe2-4792-991e-2573e7b4d3ac
# ╟─61e41405-6d51-48df-bf5e-f9bdd56798f0
# ╠═d4e9d58e-45c7-4159-8a5d-f7ecb76f351d
# ╟─4266c21c-1a80-4510-9132-7e0180edc09b
# ╠═2ed805a0-da3a-4cf5-bf33-c83e8a751e13
# ╟─4947d4ea-2aa2-4beb-86d3-edaaa9a8a185
# ╠═e1e9fede-ed34-4dcd-9406-ee3fa73a208b
# ╟─d088e43b-70e7-4b48-a9a8-f813135642b4
# ╟─fd634b44-8bbe-45b1-af82-2df66523ba3d
# ╠═54bd2a6f-e0da-4daa-8311-660e99781fb2
# ╟─6b80b81a-9ff3-479c-a91d-028f59ec5676
# ╠═56c0ec4c-5d66-4392-b09f-4a1620e75ca4
# ╠═31183b0e-1d6a-4c4b-aab0-33bb192a5d1c
# ╟─c361b02d-39a2-460b-8ee3-15064a44831b
# ╠═d19a8c9c-cb73-4359-a04c-3fdf29164f57
# ╟─84bce692-d6b4-4b63-8372-0338cd0d5203
# ╠═ba64fd9a-28f0-4ba1-9cbc-5b810c064f51
# ╟─5d6d52ea-ac32-459a-b0cf-5dbf86067701
# ╠═7e6a4f85-0621-4006-a349-45eb838f8a1c
# ╟─f1b3d924-0be3-4c80-8acf-ebb884909e51
# ╠═338453b6-2f9a-4285-81d5-190267691bdc
# ╟─ba8d0ce5-8b0b-42b3-b972-f9237a9286a0
# ╠═18e10a61-75af-48bd-908c-70208d6107d3
# ╠═5ec1d645-6006-4bac-aab4-7571d56a55b8
# ╟─1b0cfcad-8ac1-45ef-a9d5-4a931e0020b8
# ╠═6dc2da38-78d1-4f54-ab8f-58a3f7ee3a29
# ╟─c5a5a12b-0f82-4cdf-8ecf-312700702d6e
# ╟─d52ad3fb-a05a-43f2-a428-f18e7396cb96
# ╠═6af6caf9-19c2-4a1a-8dc2-7c88e34d4f7e
# ╠═4c5ad925-e262-4d94-a2c5-09d35acdf162
# ╟─914fdb0a-cfe2-4e1a-820c-02c115234099
# ╠═0122acf5-048c-49b5-a565-8ba26a8c413f
# ╟─eb5b9a2d-decd-4317-b2a2-02f114eb5fe9
# ╟─14b58a53-7e37-40aa-858a-79143742f42e
# ╠═c051efa2-4158-41db-abf0-fc0bb73fbf5b
# ╠═236fe77c-e0e2-469a-8e8b-39a0fdc5c341
# ╟─60e37fef-01f3-4dd2-a689-66dde3a6374b
# ╠═ac4ae73a-6ffa-4c98-a83c-30ea1e919d2e
# ╠═74cf2052-93db-461f-b577-ab055561fa27
# ╟─ff7c6e52-ac41-4ee5-b1c7-c65ebe27cd72
# ╟─77d96b23-ae46-4086-94cd-553924436ec4
# ╠═36e2ffc0-8ea3-4925-adf3-747d8574cb4b
# ╠═8e34ab6f-d6d8-46e2-af4e-8d65a42e7076
# ╟─44a2dd9b-70d6-41dc-ac66-f2fdd8cec8ba
# ╠═39b3fcff-6d0a-48e9-af1c-fc963d2c8078
# ╠═bb24d6cb-aaf0-42de-b0f1-c5a522ca8f0b
# ╠═b0f01d8d-52a9-4a62-a5d7-974c93334e9e
# ╠═894de4bd-d265-4346-acb4-0c52a180563b
# ╟─03ab549d-b7b8-43ad-87f5-e6d23b448304
# ╠═57147368-ca07-44b7-9402-dcdc901e915e
# ╟─6c4eed79-7480-4644-9193-d93f093395d2
# ╠═a3e7cac8-e371-4ea3-814e-ff4b94b6ba49
# ╠═de6ad70a-62e9-4e1b-bd14-5d5355f2f9cd
# ╠═8fa21201-6538-4ce6-9b48-54340d4731a9
# ╟─26d6c81f-5fbd-4042-ac5b-fba06fb823af
# ╠═80b29892-8c50-475a-9b08-d46864a2ef67
# ╠═ba89c224-828e-4f92-9f9d-1f848277355f
# ╠═cc527e49-af3d-4caf-b828-707ba8fc2890
# ╠═e36e29bb-8b72-4646-bf0a-57b5307d240f
# ╠═216e55a0-5e9b-4cd7-b39a-eb32d1f09be4
# ╟─df9caf3f-2af6-43b6-b7aa-ab9cef8a3f1b
# ╠═901085ab-96c4-4228-b00f-df8611931f3f
# ╠═3189c25a-4443-421a-8926-2090eadd80f3
# ╠═006c019e-a8e4-4697-a9b5-fd65794706c0
# ╠═cd4ff274-943e-4b36-8c2c-a1bd8de74923
# ╠═37aea785-ab84-4fcd-bf1a-19eb27b0e152
# ╟─30a90598-6539-4dc8-9fdd-7af5faa11dea
# ╠═3041ccb3-1acd-4bb1-b5b4-8a444cf8b01a
# ╠═dbbc6f23-fa5e-4b6d-942a-d90a5e25b0a3
# ╠═9529048e-55c1-48e9-9808-d5f9c840c985
# ╠═30183ec3-b4ae-4c3e-9a1a-1a98dcc9a5f2
