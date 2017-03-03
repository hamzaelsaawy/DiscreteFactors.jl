using Factors
using Base.Test
using DataFrames

include("test_dimensions.jl")

include("test_factors.jl")
include("test_factors_broadcast.jl")
include("test_factors_index.jl")
include("test_factors_iter.jl")
include("test_factors_join.jl")
include("test_factors_map.jl")
include("test_factors_reduce.jl")

include("test_dataframes.jl")
include("test_negatives.jl")
