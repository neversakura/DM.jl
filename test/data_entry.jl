using DM, Test

@testset "DataEntry" begin
    d = Dict{String,String}("alpha" => "%.2f", "beta" => "%d")
    v = Dict("alpha" => pi, "beta" => 1)
    @test "alpha=3.14_beta=1" == DM.print_params(d, v, ["alpha", "beta"])

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

    root = "test"
    folders = [["alex", "bob"], ["eve", "sandy"]]
    groups = [["anna"]]

    entry = DataEntry("test", root, params, folders, groups)

    @test DM.get_folder_path(entry, values) ==
          joinpath(root, "alex=1.20_bob=4.00/eve=25.13_sandy=0.21")
    @test DM.get_group_path(entry, values) == "anna=0.45"

    save_to_index_file("data", entry)
    @test_throws ArgumentError save_to_index_file("data", entry)
    loaded_entry = load_entry("data", "test")
    @test loaded_entry |> get_root == joinpath("data", root)
    @test loaded_entry |> get_params_fmt == params
    @test loaded_entry |> get_name == "test"
    rm("data/index.jld2")
end