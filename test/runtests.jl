using DM, Test

@testset "DataEntry" begin
        activate_param_set("task/params.json")
        d, v = load_config_from_json("task/test_1.json")
        d1 = d["task1"]
        d2 = d["task2"]
        @test DM.get_folder_path(d1, v) ==
              joinpath("./data", "alex=1.20_bob=4.00/eve=25.13_sandy=0.21")
        @test DM.get_group_path(d1, v) == "anna=0.45"
        test_data = range(0, stop = 1, length = 100)
        @info "Saving test jld file."
        save(d1, v, "data.jld", "x", test_data)
        save(d1, v, "data-1.jld", "x", test_data)
        save(d1, v, "data-2.jld", "x", test_data)
        @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.jld")
        @test check(d1, v, "data.jld", "x") == true
        @test load_file_array(d1, v, "data", "x") == [test_data, test_data]
        save(d2, v, "data.jld", "x", test_data)
        @test isfile("./data/alex=1.20_bob=4.00_eve=25.13_sandy=0.21/data.jld")
        @test check(d2, v, "data.jld", "x") == true
        @test load(d2, v, "data.jld", "x") == test_data
        test_entry = DataEntry("./data", [[]], [[]])
        save(test_entry, Dict(), "test.jld", "x", test_data)
        @test isfile("./data/test.jld")

        @info "Deleting saved jld file."
        delete(d1, v, "data.jld")
        delete(d1, v, "data-1.jld")
        delete(d1, v, "data-2.jld")
        delete(d2, v, "data.jld")
        delete(test_entry, Dict(), "test.jld")
        #rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.jld")
        #rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data-1.jld")
        #rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data-2.jld")
        #rm("./data/test.jld")
end

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
end

@testset "CSV file support" begin
        activate_param_set("task/params.json")
        d, v = load_config_from_json("task/test_1.json")
        df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
        @info "Saving test CSV file."
        save(d["task1"], v, "test.csv", df)
        @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/test.csv")
        @test load(d["task1"], v, "test.csv") == df
        if Sys.iswindows()
                GC.gc()
        end
        @info "Deleting saved CSV file."
        delete(d["task1"], v, "test.csv")
        #rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/test.csv")
end

@testset "HDF5 file support" begin
        activate_param_set("task/params.json")
        d, v = load_config_from_json("task/test_1.json")
        d = d["task1"]
        test_data = collect(range(0, stop = 1, length = 100))
        @info "Saving test hdf5 file."
        save(d, v, "data.h5", "x", test_data)
        save(d, v, "data.h5", "y", [1, 2, 3], "z", "hello")
        writeattr(d, v, "data.h5", "test_attr", "test_val")
        @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.h5")
        @test check(d, v, "data.h5", "x") == true
        test_x = load(d, v, "data.h5", "x")
        @test test_x == test_data
        @test readattr(d, v, "data.h5", "test_attr") == "test_val"
        delete(d, v, "data.h5", "y", "z")
        @test !check(d, v, "data.h5", "y")
        @info "Deleting saved hdf5 file."
        delete(d, v, "data.h5")
        #rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.h5")
end
