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
# TODO find a better error type for NegativeError

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
    scope,
    potential,
    lengths,
    getdim,
    pattern,
    pattern_states,
    getdim,
    reducedim!,

    # negatives stuff
    set_negative_mode,
    NegativeMode,
    NegativeIgnore,
    NegativeWarn,
    NegativeError

include("dimensions.jl")

include("factors_main.jl")
#include("factors_index.jl")
include("factors_iter.jl")
#include("factors_dims.jl")

include("negatives.jl")
include("dataframes.jl")
include("io.jl")
include("auxiliary.jl")
include("errors.jl")

end # module
