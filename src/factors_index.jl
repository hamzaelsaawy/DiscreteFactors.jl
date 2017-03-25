#
# Factors Indexing
#

Base.getindex(ϕ::Factor, ::Colon) = Factor(ϕ.dimensions, ϕ.potential[:])

Base.getindex(ϕ::Factor, Is::Pair{Symbol}...) = ϕ[Assignment(Is...)]

function Base.getindex(ϕ::Factor, a::Assignment)
    (I, dims) = _translate_index(ϕ, a)
    return Factor(dims, ϕ.potential[I...])
end

Base.setindex!(ϕ::Factor, v, ::Colon) = (ϕ.potential[:] = v)

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
    at2sub(ϕ::Factor, at::Vararg{Any, K}) -> subscript

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
    at2a(ϕ::Factor, at::Vararg{Any, K}) -> Assignment

Convert an assignment tuple to an Assignment.
"""
at2a(ϕ::Factor, at::Vararg{Any}) = Dict( s => v for (s, v) in zip(names(ϕ), at) )

"""
    a2at(ϕ::Factor, a::Assignment) -> Tuple
    a2at(ϕ::Factor, a::Pair{Symbol}...) -> Tuple

Convert an assignment to an assignment tuple.
"""
a2at(ϕ::Factor, pairs::Pair{Symbol}...) = a2at(ϕ, Assignment(pairs...))
a2at{N}(ϕ::Factor{N}, a::Assignment) =
    ntuple(Val{N}) do k
        d = ϕ.dimensions[k]
        n = name(d)

        @boundscheck haskey(a, n) || assignment_missing_error(n)
        return a[n]
    end

"""
    a2sub(ϕ::Factor, a::Assignment) -> subscript
    a2sub(ϕ::Factor, a::Pair{Symbol}...) -> subscript

Convert an assignment to a subscript. All variables in scope specified as a single value.
"""
a2sub(ϕ::Factor, pairs::Pair{Symbol}...) = a2sub(ϕ, Assignment(pairs...))
a2sub(ϕ::Factor, a::Assignment) = at2sub(ϕ, a2at(ϕ, a)...)

"""
    sub2a(ϕ::Factor, i::Integer...) -> Assignment

Convert a subscript into an assignment.
"""
sub2a(ϕ::Factor, I::Integer...) = at2a(ϕ, sub2at(ϕ, I...)...)
