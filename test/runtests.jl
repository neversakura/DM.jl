using DM, Test

@testset "Parameter Set" begin
    d = Dict{String,String}("alpha" => "%.2f", "beta" => "%d")
    v = Dict("alpha" => pi, "beta" => 1)
    activate_param_set(d)
    @test get_param_set() == d
    @test "alpha=3.14_beta=1" == DM.print_params(d, v, ["alpha", "beta"])
    activate_param_set("alpha" => "%.2f", "beta" => "%d")
    @test get_param_set() == d
    activate_param_set("task/params.json")
    exp = Dict{String,String}(
                "alex" => "%.2f",
                "bob" => "%.2f",
                "eve" => "%.2f",
                "sandy" => "%.2f",
                "anna" => "%.2f",
        )
    @test get_param_set() == exp

    activate_param_set("task/params.json")
    d, v = load_config_from_json("task/test_1.json")
    d1 = d["task1"]
    d2 = d["task2"]
    @test DM.get_folder_path(d1, v) ==
              joinpath("./data", "alex=1.20_bob=4.00/eve=25.13_sandy=0.21")
    @test DM.get_group_path(d1, v) == "anna=0.45"
end

@testset "HDF5 file support" begin
    activate_param_set("task/params.json")
    d, v = load_config_from_json("task/test_1.json")
    d1 = d["task1"]
    d2 = d["task2"]
    test_data = collect(range(0, stop=1, length=100))
    @info "Saving test hdf5 file."
    save(d1, v, "data.h5", "x", test_data)
    save(d1, v, "data.h5", "y", [1, 2, 3], "z", "hello")
    testattrs = Dict("test_attr_1"=>"test_val_1", "test_attr_2"=>2)
    testattrs_x = Dict("test_attr_1" => 1.2, "test_attr_2"=> "test_val_2")
    writeattr(d1, v, "data.h5", testattrs)
    writeattr(d1, v, "data.h5", "x", testattrs_x)
    @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.h5")
    @test check(d1, v, "data.h5", "x") == true
    @test load(d1, v, "data.h5", "x") == test_data
    test_x = load(d1, v, "data.h5")
    @test read(test_x["anna=0.45/x"]) == test_data
    close(test_x)
    loaded_attrs = readattr(d1, v, "data.h5")
    loaded_attrs_x = readattr(d1, v, "data.h5", "x")
    @test loaded_attrs["test_attr_1"] == "test_val_1"
    @test loaded_attrs_x["test_attr_1"] ≈ 1.2
    @test readattr(d1, v, "data.h5", ["test_attr_2"])["test_attr_2"] == 2
    @test readattr(d1, v, "data.h5", "x", ["test_attr_2"])["test_attr_2"] == "test_val_2"
    save(d2, v, "data.h5", "x", test_data)
    @test isfile("./data/alex=1.20_bob=4.00_eve=25.13_sandy=0.21/data.h5")
    delete(d1, v, "data.h5", "y", "z")
    @test !check(d1, v, "data.h5", "y")
    @info "Deleting saved hdf5 file."
    delete(d1, v, "data.h5")
    delete(d2, v, "data.h5")

    save(d1, v, "data-1.h5", "x", test_data)
    save(d1, v, "data-2.h5", "x", test_data)
    load_file_array(d1, v, "data", "x") == [test_data, test_data]
    delete(d1, v, "data-1.h5")
    delete(d1, v, "data-2.h5")

    test_entry = DataEntry("./data", [[]], [[]])
    save(test_entry, Dict(), "test.h5", "x", test_data)
    @test isfile("./data/test.h5")
    @test load(test_entry, Dict(), "test.h5", "x") == test_data
    delete(test_entry, Dict(), "test.h5")
end

@testset "CSV file support" begin
    activate_param_set("task/params.json")
    d, v = load_config_from_json("task/test_1.json")
    df = DataFrame(A=1:4, B=["M", "F", "F", "M"])
    @info "Saving test CSV file."
    save(d["task1"], v, "test.csv", df)
    @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/test.csv")
    @test load(d["task1"], v, "test.csv") == df
    if Sys.iswindows()
        GC.gc()
    end
    @info "Deleting saved CSV file."
    delete(d["task1"], v, "test.csv")
end

@testset "Utility function" begin
    test_array = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    @test convert_recursive_array(test_array) == [[1, 2, 3] [4, 5, 6] [7, 8, 9]]
    test_array = [[[1,2],[3,4]],[[5,6],[7,8]],[[9,10],[10,11]]]
    @test convert_recursive_array(test_array) == cat([hcat(x...) for x in test_array]..., dims=3)
    test_dict = parse_string_to_num(Dict("hello"=>"2*pi"))
    @test test_dict["hello"] ≈ 2π
end