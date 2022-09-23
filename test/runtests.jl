using SafeTestsets

@time begin
    @time @safetestset "Base Utilities" begin
        include("data_entry.jl")
    end
    @time @safetestset "JLD2 Test" begin
        include("jld2.jl")
    end
    @time @safetestset "HDF5 Test" begin
        include("hdf5.jl")
    end
    @time @safetestset "CSV Test" begin
        include("csv.jl")
    end
    @time @safetestset "Utilities" begin
        include("utilities.jl")
    end
end