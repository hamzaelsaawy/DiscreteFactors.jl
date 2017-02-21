using Factors
using Base.Test
using DataFrames

include("test_dimensions.jl")
println("dimensions passes")

include("test_factors.jl")
info("factors passes")

include("test_factors_access.jl")
info("factors access passes")

include("test_factors_dims.jl")
info("factors dims passes")

