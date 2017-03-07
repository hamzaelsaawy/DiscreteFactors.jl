# __precompile__(true)

# TODO update(::Vector{Bool}) check if same length
# TODO x/0 = 0
# TODO ϕ .< 3, ϕ1 == ϕ2, etc...
# TODO push(ϕ, dims...), push(ϕ, Pair{Symbol}...)
# TODO broadcast_reduce
# TODO broadcast fallback for empty arrays
# TODO broadcast_reduce tag-team
# TODO map_reduce as well
# TODO better / faster broadcast
# TODO implement inner joins
# TODO better error type for NegativeError
# TODO add @boundscheck and @inbounds where applicable

module Factors

import Base: .==, .!=, .<, .<=, .>, .>=, in, ==, *, /, +, -,
        show, reducedim, broadcast, broadcast!,
        show, join, hash
import Base.LinAlg: normalize, normalize
import DataFrames

export
    # Dimension stuff
    Dimension,
    RangeDimension,

    name,
    eltype,
    support,
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
    push,
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
