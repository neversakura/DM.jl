using Documenter, DM

makedocs(
    modules = [DM],
    clean = false,
    sitename="DM.jl",
    pages= [
        "Home" => "index.md",
    ],
)

deploydocs(
    repo = "github.com/neversakura/DM.jl.git",
    target = "build"
)
