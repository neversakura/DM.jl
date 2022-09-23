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
data = collect(range(0, stop=1, length=100))
save(entry, values, "data.jld2", "x", data)
save(entry, values, "data.jld2", "y", [1, 2, 3], "z", "hello")
@test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/data.jld2")
@test check(entry, values, "data.jld2", "x") == true
@test load(entry, values, "data.jld2", "x") == data
test_x = load(entry, values, "data.jld2")
@test test_x["anna=0.45/x"] == data

Sys.iswindows() && GC.gc()
delete(entry, values, "data.jld2")