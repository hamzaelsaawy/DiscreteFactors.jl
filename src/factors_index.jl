#
# Factors Indexing
#
# For ϕ[:A] syntax and such

# Column access (ϕ[:A]) returns the dimension for comparisons and stuff
Base.getindex(ϕ::Factor, dim::Symbol) = getdim(ϕ, dim)
Base.getindex(ϕ::Factor, dims::Vector{Symbol}) = getdim(ϕ, dims)

# TODO setindex for ϕ[dim]
# TODO (:X => ...) to (5, ...)
# TODO ϕ[:X=> ...]
# TODO ϕ[:]

# Index by number gets that ind
#Base.getindex(ϕ::Factor, i::Int) = ϕ.v[i]
#Base.getindex(ϕ::Factor, I::Vararg{Int}) = ϕ.v[I]

Base.getindex(ϕ::Factor, Is::Pair{Symbol}...) = ϕ[Assignment(Is...)]
function Base.getindex(ϕ::Factor, a::Assignment)
    (I, dims) = _translate_index(ϕ, a)
    return Factor(dims, ϕ.potential[I])
end

Base.setindex!(ϕ::Factor, v, Is::Pair{Symbol}...) = setindex!(ϕ, v, Assignment(Is...))
function Base.setindex!(ϕ::Factor, v, a::Assignment)
    return ϕ.potential[sub2ind(a)] = v
end

function _translate_index(ϕ::Factor, a::Assignment)
    ind = Array{Any}(ndims(ϕ))
    # all dimensions are accessed by default
    ind[:] = Colon()

    I = Array{Any}(ndims(ϕ))
    I[:] = Colon()
    dims = copy(scope(ϕ))
    for (i, d) in enumerate(scope(ϕ))
        n = name(d)
        if haskey(a, n)
            (ind, new_d) = update(d, a[n])
            I[i] = ind
            dims[i] = new_d
        end
    end

    dims = filter(d -> ~isempty(d), dims)
    return (I, dims)
end

"""
    sub2ind(ϕ::Factor, a::Assignment)

Return the index of the assignment.
"""
function Base.sub2ind(ϕ::Factor, a::Assignment)
    (I, _) = _translate_index(ϕ, a)
    return I
end

"""
    ind2sub(ϕ::Factor, i::Int)

Returns the assignment corresponding to index `i`.
"""
function Base.ind2sub{N}(ϕ::Factor{N}, i)
    I = ind2sub(size(ϕ), i)
    return ntuple(k -> ϕ.dimensions[k][sb[k]], Val{N})
end
