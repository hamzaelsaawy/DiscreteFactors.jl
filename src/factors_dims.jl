#
# Factors Reduce
#
# Dimension specific things, like broadcast, reduce, sum, etc.
# Functions (should) leave ft the same if dim ∉ ft

# opt for a more efficient version than reducedim!(deepcopy(ft))
"""
Reduces a dimension in `ft` using function `op`.
See Base.reducedim for more details
"""
function Base.reducedim{D<:Dimension, V<:Number}(op, ft::Factor{D, V},
        dims, v0=nothing)
    if isa(dims, Symbol)
        dims = [dims]
    elseif isa(dims, Vector{Symbol})
        dims = unique(dims)
    else
        invalid_dims_error()
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

function reducedim!{D<:Dimension, V<:Number}(op, ft::Factor{D, V}, dims, 
        v0=nothing)
    if isa(dims, Symbol)
        dims = [dims]
    elseif isa(dims, Vector{Symbol})
        dims = unique(dims)
    else
        invalid_dims_error()
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

        ft.v = v_new
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

"""
Broadcast a vector (or array of vectors) across the dimension(s) `dims`

To broadcast the same vector across multiple dimensions, multiple
calls to broadcast(f, ft, ...) are necessary. Otherwise, broadcasting
a for each value in a dimension for multiple dimensions and broadcasting
a vector across multiple dimensions

See Base.broadcast for more info.
"""
Base.broadcast(f, ft::Factor, dims, values) =
    broadcast!(f, deepcopy(ft), dims, values)


"""
Broadcast a vector (or array of vectors) across the dimension(s) `dims`

To broadcast the same vector across multiple dimensions, multiple
calls to broadcast(f, ft, ...) are necessary. Otherwise, broadcasting
a for each value in a dimension for multiple dimensions and broadcasting
a vector across multiple dimensions

See Base.broadcast for more info.
"""
function Base.broadcast!(f, ft::Factor, dims, values)
    if isa(dims, Symbol)
        dims = [dims]
        values = [values]
    elseif isa(dims, Vector{Symbol})
        if !allunique(dims)
            non_unique_dims_error()
        end
        if length(dims) != length(values)
            throw(ArgumentError("Number of dimensions does not " *
                        "match number of values to broadcast"))
        end
    else
        invalid_dims_error()
    end

    inds = findin(ft, dims)
    # get rid of dimensions not in ft
    inds = inds[inds .!= 0]
    dims = dims[inds .!= 0]
    values = values[inds .!= 0]

    # check all the dimensions match first
    #  or its a singleton value
    if any( (length(ft, dims) .!= map(length, values)) &
            (map(length, values) .!= 1) )
        throw(ArgumentError("Length of dimensions don't match " *
                    "lengths of broadcast array"))
    end

    # actually broadcast stuff
    for (i, val) in enumerate(values)
        if isa(val, Array)
            # reshape to the proper dimension

            # reshape takes a tuple
            reshape_dims = (vcat(ones(Int, inds[i]-1), length(val))...)
            val = reshape(val, reshape_dims)
        end
        broadcast!(f, ft.v, ft.v, val)
    end

    return ft
end

