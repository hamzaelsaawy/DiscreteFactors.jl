# __precompile__(true)

# TODO update(::Vector{Bool}) check if same length
# TODO unparameterize factors
# TODO x/0 = 0
# TODO non-negative warning?
# TODO FloatRange dimension and indexin?
# TODO indexing with pairs vs assignment
# TODO more constructors paris of symbol to ranges
# TODO add FactorView or subarray version to access subarray, then squeeze ...
# TODO broadcast_reduce
# TODO sub2ind for Assignments
# TODO sub2ind for assignments
# TODO broadcast fallback for empty arrays
# TODO broadcast_reduce tag-team

module Factors

import Base: .==, .!=, .<, .<=, .>, .>=, in, ==, *, /, +, -,
        show, reducedim, broadcast, broadcast!,
        show, sum, prod, maximum, minimum, join
import Base.LinAlg: normalize, normalize
import DataFrames

export
    Dimension,
    RangeDimension,
    StepDimension,
    UnitDimension,
    CartesianDimension,

    name,
    eltype,
    dimension,
    update,

    Assignment,

    Factor,
    scope,
    lengths,
    getdim,
    pattern,
    pattern_states
#=    getdim,
    reducedim!
=#
include("dimensions.jl")
include("factors_main.jl")
#include("factors_access.jl")
#include("factors_dims.jl")
include("dataframes.jl")
include("errors.jl")
include("auxiliary.jl")
include("io.jl")

end # module

