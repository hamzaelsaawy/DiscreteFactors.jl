#
# Factors Reduce
#

# reduce the dimension and then squeeze them out
_red_dim(op, ϕ::Factor, inds::Tuple, ::Void) = squeeze(reducedim(op, ϕ.potential, inds), inds)
_red_dim(op, ϕ::Factor, inds::Tuple, v0) = squeeze(reducedim(op, ϕ.potential, inds, v0), inds)

"""
    reducedim(op, ϕ::Factor, dims, [v0])

Reduces a dimension in `ϕ` using function `op`.
See `Base.reducedim` for more details
"""
Base.reducedim(op, ϕ::Factor, dim::Symbol, v0=nothing) = reducedim(op, ϕ, [dim], v0)

# a more efficient version than `reducedim!(deepcopy(ϕ))` ?
function Base.reducedim(op, ϕ::Factor, dims::Vector{Symbol}, v0=nothing)
    _check_dims_valid(dims, ϕ)
    # needs to be a tuple for squeeze
    inds = (sort!(indexin(dims, ϕ)])...)

    isempty(inds) && return deepcopy(ϕ)

    dims_new = deepcopy(ϕ.dimensions)
    deleteat!(dims_new, inds)
    pot_new = _red_dim(op, ϕ, inds, v0)

    return Factor(dims_new, v_new)
end

"""
    reducedim!(op, ϕ::Factor, dims, [v0])

Reduces a dimension in `ϕ` using function `op`.
See `Base.reducedim!` for more details
"""
Base.reducedim!(op, ϕ::Factor, dim::Symbol, v0=nothing) = reducedim(op, ϕ, [dim], v0)

function reducedim!{D<:Dimension, V<:Number}(op, ϕ::Factor{D, V}, dims, v0=nothing)
    _check_dims_valid(dims, ϕ)
    # needs to be a tuple for squeeze
    inds = (sort!(indexin(dims, ϕ)])...)

    isempty(inds) && return ϕ

    deleteat!(ϕ.dimensions, inds)
    pot_new = _red_dim(op, ϕ, inds, v0)
    ϕ.potential = pot_new

    return ϕ
end

"""
    Z(ϕ::Factor)

Return the partition function.
"""
Z(ϕ::Factor) = sum(ϕ)

Base.sum(ϕ::Factor, dims=names(ϕ)) = reducedim(+, ϕ, dims)
Base.sum!(ϕ::Factor, dims=names(ϕ)) = reducedim!(+, ϕ, dims)
Base.prod(ϕ::Factor, dims=names(ϕ)) = reducedim(*, ϕ, dims)
Base.prod!(ϕ::Factor, dims=names(ϕ)) = reducedim!(*, ϕ, dims)
Base.maximum(ϕ::Factor, dims=names(ϕ)) = reducedim(max, ϕ, dims)
Base.maximum!(ϕ::Factor, dims=names(ϕ)) = reducedim!(max, ϕ, dims)
Base.minimum(ϕ::Factor, dims=names(ϕ)) = reducedim(min, ϕ, dims)
Base.minimum!(ϕ::Factor, dims=names(ϕ)) = reducedim!(min, ϕ, dims)
