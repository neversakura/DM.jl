using DM, Test

@testset "DataEntry" begin
        activate_param_set("task/params.json")
        d, v = load_config_from_json("task/test_1.json")
        @test DM.get_folder_path(d ,v) == "./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/"
        @test DM.get_group_path(d, v) == "anna=0.45/"
        test_data = range(0,stop=1,length=100)
        @info "Saving test data to file."
        save(d, v, "data.jld2", "x", test_data)
        @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.jld2")
        @test check(d, v, "data.jld2", "x") == true
        #set_value!(d, 0.5, "anna")
        #@test dm_check(d, "data.jld2", "x") == false
        d2, v2 = load_config_from_json("task/test_2.json")
        test_x = load(d, v2, "data.jld2", "x")
        @test test_x == test_data
        @info "Deleting saved data file."
        rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.jld2")
end

@testset "Iteration" begin
        activate_param_set("task/params.json")
        anna_val = ["anna=0.10/","anna=0.50/","anna=1.00/"]
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
