# __precompile__(true)

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
        OneTo, indexin, findfirst, reducedim, broadcast, broadcast!,
        show, sum, prod, maximum, minimum, join
import Base.LinAlg: normalize, normalize
import DataFrames

export
    ListDimension,
    StepDimension,
    UnitDimension,
    CartesianDimension,

    name,
    eltype,
    dimension,

    Assignment,

    Factor,
    lengths,
    pattern,
    pattern_states,
#=    getdim,
    reducedim!
=#
include("errors.jl")
include("auxilary.jl")
include("dimensions.jl")
include("factors_main.jl")
#include("factors_access.jl")
#include("factors_dims.jl")
#include("factors_dataframes.jl")
include("io.jl")

end # module

