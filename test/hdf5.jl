using DM, Test

params = Dict(
    "alex" => "%.2f",
    "bob" => "%.2f",
    "eve" => "%.2f",
    "sandy" => "%.2f",
    "anna" => "%.2f"
)

values = Dict(
    "alex" => 1.2,
    "bob" => 4,
    "eve" => 8*pi,
    "sandy" => 0.21,
    "anna" => 1/2.23
)

root = "data"
folders = [["alex", "bob"], ["eve", "sandy"]]
groups = [["anna"]]

entry = DataEntry("test", root, params, folders, groups)


test_data = collect(range(0, stop=1, length=100))

save(entry, values, "data.h5", "x", test_data)
save(entry, values, "data.h5", "y", [1, 2, 3], "z", "hello")
testattrs = Dict("test_attr_1"=>"test_val_1", "test_attr_2"=>2)
testattrs_x = Dict("test_attr_1" => 1.2, "test_attr_2"=> "test_val_2")
writeattr(entry, values, "data.h5", testattrs)
writeattr(entry, values, "data.h5", "x", testattrs_x)
@test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.h5")
@test check(entry, values, "data.h5", "x") == true
@test load(entry, values, "data.h5", "x") == test_data
test_x = load(entry, values, "data.h5")
@test read(test_x["anna=0.45/x"]) == test_data
close(test_x)
loaded_attrs = readattr(entry, values, "data.h5")
loaded_attrs_x = readattr(entry, values, "data.h5", "x")
@test loaded_attrs["test_attr_1"] == "test_val_1"
@test loaded_attrs_x["test_attr_1"] ≈ 1.2
@test readattr(entry, values, "data.h5", ["test_attr_2"])["test_attr_2"] == 2
@test readattr(entry, values, "data.h5", "x", ["test_attr_2"])["test_attr_2"] == "test_val_2"

delete(entry, values, "data.h5", "y", "z")
@test !check(entry, values, "data.h5", "y")

Sys.iswindows() && GC.gc()
delete(entry, values, "data.h5")

save(entry, values, "data-1.h5", "x", test_data)
save(entry, values, "data-2.h5", "x", test_data)
load_file_array(entry, values, "data", "x") == [test_data, test_data]
Sys.iswindows() && GC.gc()
delete(entry, values, "data-1.h5")
delete(entry, values, "data-2.h5")

entry_empty_list = DataEntry("empty_list_test", "./data", params, [[]], [[]])
save(entry_empty_list, Dict(), "test.h5", "x", test_data)
@test isfile("./data/test.h5")
@test load(entry_empty_list, Dict(), "test.h5", "x") == test_data
Sys.iswindows() && GC.gc()
delete(entry_empty_list, Dict(), "test.h5")