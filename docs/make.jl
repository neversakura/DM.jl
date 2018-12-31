using Documenter, DM

makedocs(
    sitename="DM.jl",
    pages= [
        "Home" => "index.md",
        "Library" => Any[
            "Public" => "lib/public.md"
        ]
    ]
)

deploydocs(
    repo = "github.com/neversakura/DM.jl.git",
)
