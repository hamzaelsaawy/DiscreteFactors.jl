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
# TODO map_reduce as well
# TODO inner join
# TODO find a better error type for NegativeError
# TODO add @boundscheck and @inbounds where applicable

module Factors

import Base: .==, .!=, .<, .<=, .>, .>=, in, ==, *, /, +, -,
        show, reducedim, broadcast, broadcast!,
        show, sum, prod, maximum, minimum, join
import Base.LinAlg: normalize, normalize
import DataFrames

export
    # Dimension stuff
    Dimension,
    RangeDimension,

    name,
    eltype,
    spttype,
    update,

    Assignment,

    Factor,
    # basic access
    scope,
    potential,
    lengths,
    # interact with dimensions
    getdim,
    pattern,
    pattern_states,
    getdim,
    reducedim!,
    # assignment conversions
    at2sub,
    sub2at,
    at2a,
    a2at,
    a2sub,
    sub2a,

    # negatives stuff
    set_negative_mode,
    NegativeMode,
    NegativeIgnore,
    NegativeWarn,
    NegativeError

include("dimensions.jl")   # define Dimension
include("factors_main.jl") # define Factors
include("auxiliary.jl")    # define Assignment

include("factors_broadcast.jl")
include("factors_index.jl")
include("factors_iter.jl")
include("factors_join.jl")
include("factors_map.jl")
include("factors_reduce.jl")

include("dataframes.jl")
include("errors.jl")
include("io.jl")
include("negatives.jl")

end # module
