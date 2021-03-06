__precompile__(true)

# TODO x/0 = 0
# TODO ϕ * 2, ϕ1 + 5, etc...
# TODO ϕ .< 3, ϕ1 == ϕ2, etc... (how would this work?)
# TODO assignment tuple indexing, e.g. ϕ["a", 1]
# TODO push(ϕ, dims...), push(ϕ, Pair{Symbol}...)
# TODO better / faster broadcast
# TODO custom error type for NegativeError
# TODO also, better error type of others (e.g. Bounds error, DimensionMismatch, ...)
# TODO broadcast_reduce tag-team
# TODO map_reduce as well
# TODO add @boundscheck and @inbounds where applicable

module Factors

import Base: .==, .!=, .<, .<=, .>, .>=, in, ==, *, /, +, -, hash
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
    Z,
    marginalize,
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
