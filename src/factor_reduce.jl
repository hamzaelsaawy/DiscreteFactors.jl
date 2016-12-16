# leave ft the same if dim ∉ ft
# opt for a more efficient version than reducedim!(deepcopy(ft))

"""
Reduces a dimension in `ft` using function `op`.
See Base.reducedim for more details
"""
function Base.reducedim{D<:Dimension, V<:Number}(op, ft::Factor{D, V},
        dims, v0=nothing)
    if isa(dims, Symbol)
        dims = [dims]
    else
        dims = unique(dims)
    end

    inds = findin(ft, dims)
    # get rid of dimensions not in ft
    inds = sort!(inds[inds .!= 0])

    if !isempty(inds)
        # needs to be a tuple for squeeze
        inds = (inds...)

        dims_new = deepcopy(ft.dimensions)
        deleteat!(dims_new, inds)

        if v0 != nothing
            v_new = squeeze(reducedim(op, ft.v, inds, v0), inds)
        else
            v_new = squeeze(reducedim(op, ft.v, inds), inds)
        end

        ft = Factor(dims_new, v_new)
    else
        ft = deepcopy(ft)
    end

    return ft
end

function reducedim!{D<:Dimension, V<:Number}(ft::Factor{D, V},
        dims, v0)
    if isa(dims, Symbol)
        dims = [dims]
    else
        dims = unique(dims)
    end

    inds = findin(ft, dims)
    # get rid of dimensions not in ft
    inds = sort!(inds[inds .!= 0])

    if !isempty(dims)
        # needs to be a tuple for squeeze
        inds = (inds...)

        if v0 != nothing
            v_new = squeeze(reducedim(op, ft.v, inds, v0), inds)
        else
            v_new = squeeze(reducedim(op, ft.v, inds), inds)
        end

        deleteat!(ft.dimensions, inds)
    end

    return ft
end

Base.sum(ft::Factor, dims) = reducedim(+, ft, dims)
Base.sum!(ft::Factor, dims) = reducedim!(+, ft, dims)
Base.prod(ft::Factor, dims) = reducedim(*, ft, dims)
Base.prod!(ft::Factor, dims) = reducedim!(*, ft, dims)
Base.maximum(ft::Factor, dims) = reducedim(max, ft, dims)
Base.maximum!(ft::Factor, dims) = reducedim!(max, ft, dims)
Base.minimum(ft::Factor, dims) = reducedim(min, ft, dims)
Base.minimum!(ft::Factor, dims) = reducedim!(min, ft, dims)
