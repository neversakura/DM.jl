using DM, Test
@testset "DataEntry" begin
        m, d, r = load_task_from_json("test_1")
        @test get_folder_path(d) == "./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/"
        @test get_group_path(d) == "anna=0.45/"
        test_data = range(0,stop=1,length=100)
        @info "Saving test data to file."
        dm_save(d, "data.jld2", "x", test_data)
        @test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.jld2")
        @test dm_check(d, "data.jld2", "x") == true
        set_value!(d, 0.5, "anna")
        @test dm_check(d, "data.jld2", "x") == false
        m2, d2, r2 = load_task_from_json("test_2")
        test_x = dm_load_from_task(d2, "test_1", "data.jld2", "x")
        @test test_x == test_data
        @info "Deleting saved data file."
        rm("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.jld2")
end

@testset "Iteration" begin
        anna_val = ["anna=0.10/","anna=0.50/","anna=1.00/"]
        m, d, rn, rv = load_task_from_json("test_range")
        for (v_set,expected) in zip(rv, anna_val)
                set_value!(d, v_set, rn)
                @test get_group_path(d) == expected
        end
end
