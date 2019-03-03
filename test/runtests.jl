using DM, Test

@testset "DataEntry" begin
        activate_param_set("task/params.json")
        d, v = load_config_from_json("task/test_1.json")
        @test DM.get_folder_path(d ,v) == "./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21"
        @test DM.get_group_path(d, v) == "anna=0.45"
        test_data = range(0,stop=1,length=100)
        @info "Saving test jld2 file."
        save(d, v, "data.jld2", "x", test_data)
        save(d, v, "data-1.jld2", "x", test_data)
        save(d, v, "data-2.jld2", "x", test_data)
        @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.jld2")
        @test check(d, v, "data.jld2", "x") == true
        @test load_file_array(d, v, "data", "x") == [test_data, test_data]
        #set_value!(d, 0.5, "anna")
        #@test dm_check(d, "data.jld2", "x") == false
        d2, v2 = load_config_from_json("task/test_2.json")
        test_x = load(d, v2, "data.jld2", "x")
        @test test_x == test_data

        test_entry = DataEntry("./data", [[]], [[]])
        save(test_entry, Dict(), "test.jld2", "x", test_data)
        @test isfile("./data/test.jld2")

        @info "Deleting saved jld2 file."
        rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.jld2")
        rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data-1.jld2")
        rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data-2.jld2")
        rm("./data/test.jld2")
end

@testset "Iteration" begin
        activate_param_set("task/params.json")
        anna_val = ["anna=0.10","anna=0.50","anna=1.00"]
        d, v = load_config_from_json("task/test_range.json")
        for (res, exp) in zip(v, anna_val)
                @test DM.get_group_path(d, res) == exp
        end
end

@testset "Parameter Set" begin
        d = Dict{String ,String}("alpha"=>"%.2f", "beta"=>"%d")
        v = Dict("alpha"=>pi, "beta"=>1)
        activate_param_set(d)
        @test get_param_set() == d
        @test "alpha=3.14_beta=1" == DM.print_params(d,v,["alpha","beta"])
        activate_param_set("alpha"=>"%.2f", "beta"=>"%d")
        @test get_param_set() == d
        activate_param_set("task/params.json")
        exp = Dict{String, String}("alex"=>"%.2f", "bob"=>"%.2f", "eve"=>"%.2f", "sandy"=>"%.2f", "anna"=>"%.2f")
        @test get_param_set() == exp
end

@testset "CSV file support" begin
        activate_param_set("task/params.json")
        d, v = load_config_from_json("task/test_1.json")
        df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"])
        @info "Saving test CSV file."
        save(d, v, "test.csv", df)
        @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/test.csv")
        @test load(d, v, "test.csv") == df
        if Sys.iswindows()
            GC.gc()
        end
        @info "Deleting saved CSV file."
        rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/test.csv")
end

@testset "HDF5 file support" begin
        activate_param_set("task/params.json")
        d, v = load_config_from_json("task/test_1.json")
        test_data = collect(range(0,stop=1,length=100))
        @info "Saving test hdf5 file."
        save(d, v, "data.h5", "x", test_data)
        save(d, v, "data.h5", "y", [1,2,3], "z", "hello")
        @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.h5")
        @test check(d, v, "data.h5", "x") == true
        test_x = load(d, v, "data.h5", "x")
        @test test_x == test_data
        delete(d, v, "data.h5", "y", "z")
        @test !check(d, v, "data.h5", "y")
        @info "Deleting saved hdf5 file."
        rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.h5")
end
