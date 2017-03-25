#
# Factors Broadcasting
#

# THIS IS VERY POORLY WRITTEN

"""
    broadcast(f, ϕ::Factor, dims, values)

Broadcast a vector (or array of vectors) across the dimension(s) `dims`

See `Base.broadcast` for more info.
"""
Base.broadcast(f, ϕ::Factor, dims, values) = broadcast!(f, deepcopy(ϕ), dims, values)


"""
    broadcast!(f, ϕ::Factor, dims, values)

Broadcast a vector (or array of vectors) across the dimension(s) `dims`

See `Base.broadcast!` for more info.
"""
Base.broadcast!(f, ϕ::Factor, dim::Symbol, values) = Base.broadcast!(f, ϕ, [dim], [values])

function Base.broadcast!(f, ϕ::Factor, dims::Vector{Symbol}, values)
    _check_dims_valid(dims, ϕ)

    (length(dims) != length(values)) &&
        throw(DimensionMismatch("Number of dimensions does not match number of values to broadcast"))

    # broadcast will check if the dimensions of each value are valid
    # check all the dimensions match or its a singleton value
    #any( (length(ϕ, dims) .!= map(length, values)) & map(length, values) .!= 1) ) &&
    #    throw(ArgumentError("Length of dimensions don't match lengths of broadcast array"))

    inds = indexin(dims, ϕ)

    # each vector gets reshaped to be 1x1... except for the index of its dimension
    reshape_dims = ones(Int, ndims(ϕ))
    new_values = Vector{Array}(length(values))

    for (i, val) in enumerate(values)
        if isa(val, Vector)
            # reshape to the proper dimension
            dim_loc = inds[i]
            reshape_dims[dim_loc] = length(val)
            new_values[i] = reshape(val, reshape_dims...)
            reshape_dims[dim_loc] = 1
        else # its a number (?)
            new_values[i] = [val]
        end
    end

    broadcast!(f, ϕ.potential, ϕ.potential, new_values...)

    return ϕ
end
