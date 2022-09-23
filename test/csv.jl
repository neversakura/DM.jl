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

df = DataFrame(A=1:4, B=["M", "F", "F", "M"])
save(entry, values, "test.csv", df)
@test isfile("./data/alex=1.20_bob=4.00/eve=25.13_sandy=0.21/test.csv")
@test load(entry, values, "test.csv") == df
Sys.iswindows() && GC.gc()
delete(entry, values, "test.csv")