#
# Factors Dimensions/Reduce
#
# Dimension specific things, like broadcast, reduce, sum, etc.

Base.in(d::Dimension, ϕ::Factor) = d in scope(ϕ)
Base.in(d::Symbol, ϕ::Factor) = d in names(ϕ)

"""
    indexin(dims, ϕ::Factor)

Find index of dimension `dims` in `ϕ`. Return 0 if not in `ϕ`.
"""
Base.indexin(dim::Symbol, ϕ::Factor) = findnext(names(ϕ), dim, 1)
Base.indexin(dims::Vector{Symbol}, ϕ::Factor) = indexin(dims, names(ϕ))

"""
    getdim(ϕ::Factor, dim::Symbol)
    getdim(ϕ::Factor, dims::Vector{Symbol})

Get the dimension with name `dim` in `ϕ`.
"""
@inline function getdim(ϕ::Factor, dim::Symbol)
    i = indexin(dim, ϕ)

    (i == 0) && not_in_factor_error(dim)

    return ϕ.dimensions[i]
end

@inline function getdim(ϕ::Factor, dims::Vector{Symbol})
    _check_dims_valid(dims, ϕ)

    inds = indexin(dims, ϕ)
    return ϕ.dimensions[inds]
end

function Base.permutedims!(ϕ::Factor, perm)
    ϕ.potential = permutedims(ϕ.potential, perm)
    ϕ.dimensions = ϕ.dimensions[perm]

    return ϕ
end

Base.permutedims(ϕ::Factor, perm) = permutedims!(deepcopy(ϕ), perm)

# opt for a more efficient version than reducedim!(deepcopy(ft))
"""
Reduces a dimension in `ft` using function `op`.
See Base.reducedim for more details
"""
function Base.reducedim{D<:Dimension, V<:Number}(op, ft::Factor{D, V}, dims, v0=nothing)
    if isa(dims, Symbol)
        dims = [dims]
    elseif isa(dims, Vector{Symbol})
        dims = unique(dims)
    else
        invalid_dims_error()
    end

    inds = indexin(dims, ft)
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

function reducedim!{D<:Dimension, V<:Number}(op, ft::Factor{D, V}, dims, v0=nothing)
    if isa(dims, Symbol)
        dims = [dims]
    elseif isa(dims, Vector{Symbol})
        dims = unique(dims)
    else
        invalid_dims_error()
    end

    inds = indexin(dims, ft)
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

"""
    Z(ϕ::Factor)

Return the partition function.
"""
Z(ft::Factor) = reducedim(+, ft, names(ft))

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
Base.broadcast(f, ft::Factor, dims, values) = broadcast!(f, deepcopy(ft), dims, values)


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

    inds = indexin(dims, ft)
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

"""
Joins two factos. Only two kinds are allowed: inner and outer

Outer returns a Factor with the union of the two dimensions
The two factors are combined with Base.broadcast(op, ...)

Inner keeps only the intersect between the two
The extra dimensions are first reduced with reducedim(reducehow, ...)
and then the two factors are combined with:
    op(ft1[intersect].v, ft2[intersect.v])
"""
function Base.join(op, ft1::Factor, ft2::Factor, kind=:outer,
        reducehow=nothing, v0=nothing)
    # dimensions in common
    #  more than just names, so will be same type, states (hopefully?)
    common = intersect(ft1.dimensions, ft2.dimensions)

    if kind == :outer
        # the first dimensions are all from ft1
        new_dims = union(ft1.dimensions, ft2.dimensions)

        # permuate the common dimensions in ft2 to the front
        perm = collect(1:ndims(ft2))
        # find which dims in ft2 are shared
        is_common2 = indexin(ft2.dimensions, common) .!= 0
        # have their indices be moved to the front
        perm = vcat(perm[is_common2], perm[!is_common2])
        temp = permutedims(ft2.v, perm)

        # now reshape it by lining up the common dims in ft2 with those in ft1
        #  boolean for which new dimensions come from ft1 only
        is_unique1 = indexin(new_dims, setdiff(ft1.dimensions, common))
        # set those dims to have dimension 1 for data in ft2
        reshape_lengths = map(length, new_dims)
        nd1 = ndims(ft1)
        new_v = duplicate(ft1.v, (reshape_lengths[(nd1+1):end]...))
        reshape_lengths[is_unique1 .!= 0] = 1

        # broadcast will automatically expand the later dimensions of ft1.v
        broadcast!(op, new_v, new_v, reshape(temp, (reshape_lengths...)))
    elseif kind == :inner
        new_dims = getdim(ft1, common)

        if isempty(common)
            # weird magic for a zero-dimensional array
            v_new = squeeze(zero(eltype(ft1), 0), 1)
        else
            if reducehow == nothing
                throw(ArgumentError("Need reducehow"))
            end

            inds1 = (findin(ft1.dimensions, common)...)
            inds2 = (findin(ft2.dimensions, common)...)

            if v0 != nothing
                v1_new = squeeze(reducedim(op, ft1.v, inds1, v0), inds)
                v2_new = squeeze(reducedim(op, ft2.v, inds2, v0), inds)
            else
                v1_new = squeeze(reducedim(op, ft1.v, inds1), inds)
                v2_new = squeeze(reducedim(op, ft2.v, inds2), inds)
        new_m = zeros(eltype(ft1.v), reshape_lengths)
            end
            v_new = op(v1_new, v2_new)
        end
    else
        throw(ArgumentError("$(kind) is not a supported join type"))
    end

    return Factor(new_dims, new_v)
end


*(ft1, ft2) = join(*, ft1, ft2)
