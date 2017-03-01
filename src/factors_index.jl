#
# Factors Indexing
#
# For ϕ[:A] syntax and such

# Column access (ϕ[:A]) returns the dimension for comparisons and stuff
# TODO column access?
#Base.getindex(ϕ::Factor, dim::Symbol) = getdim(ϕ, dim)
#Base.getindex(ϕ::Factor, dims::Vector{Symbol}) = getdim(ϕ, dims)

# TODO setindex for ϕ[dim]
# TODO ϕ[:X=> ...]
# TODO ϕ[:]


Base.getindex(ϕ::Factor, Is::Pair{Symbol}...) = ϕ[Assignment(Is...)]
function Base.getindex(ϕ::Factor, a::Assignment)
    (I, dims) = _translate_index(ϕ, a)
    return Factor(dims, ϕ.potential[I...])
end

Base.setindex!(ϕ::Factor, v, Is::Pair{Symbol}...) = setindex!(ϕ, v, Assignment(Is...))
function Base.setindex!(ϕ::Factor, v, a::Assignment)
    (I, _) = _translate_index(ϕ, a)
    return ϕ.potential[I...] = v
end

# assignment to index (as array)
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
    ind2sub(ϕ::Factor, i::Integer)

Return the subsript into `potential`
"""
Base.ind2sub(ϕ::Factor, i::Integer) = ind2sub(size(ϕ), i)

"""
    sub2ind(ϕ::Factor, i::Integer...)

Return the index into `potential`
"""
Base.sub2ind(ϕ::Factor, i::Integer...) = sub2ind(size(ϕ), i...)

"""
    a2sub(ϕ::Factor, a::Assignment) -> subscript
    a2sub(ϕ::Factor, a::Pair{Symbol}...) -> subscript

Convert an assignment to a subscript. All variables in scope specified as a single value.
"""
a2sub(ϕ::Factor, pairs::Pair{Symbol}...) = sub2ind(ϕ, Assignment(pairs...))
a2sub{N}(ϕ::Factor{N}, a::Assignment) =
    ntuple(Val{N}) do k
        d = ϕ.dimensions[k]
        n = name(d)

        @boundscheck haskey(a, n) || assignment_missing_error(n)
        return indexin(a[n], d)
    end

"""
    at2sub(ϕ::Factor, a::Tuple) -> subscript

Convert an assignment tuple to a subscript.
"""

at2sub{N, K}(ϕ::Factor{N}, vs::Vararg{Any, K}) =
    ntuple(Val{min(N, K)}) do k
        d = ϕ.dimensions[k]
        v = vs[k]

        return indexin(v, d)
    end

"""
    sub2at(ϕ::Factor, i::Integer...) -> Tuple

Convert a subscript into an assignment tuple.
"""
sub2at{N, K}(ϕ::Factor{N}, I::Vararg{Integer, K}) =
    ntuple(k -> ϕ.dimensions[k][I[k]], Val{min(N, K)})

"""
    sub2a(ϕ::Factor, i::Integer...) -> Assignment

Convert a subscript into an assignment.
"""
sub2a(ϕ::Factor, I::Integer...) = Dict( s => v for (s, v) in zip(names(ϕ), sub2at(ϕ, I...)))
