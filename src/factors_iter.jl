#
# Factors Iteration
#
# Iterating over indices, potential, etc.

Base.start(ϕ::Factor) = 1
Base.next(ϕ::Factor, i) = (sub2at(ϕ, ind2sub(ϕ, i)...), i+1)
Base.done(ϕ::Factor, i) = (i == length(ϕ))

"""
    pattern(ϕ::Factor, [dim])

Return the index of the states of `dim`, given its current position in ϕ.
"""
pattern(ϕ::Factor, dim::Symbol) = pattern(ϕ, [dim])

function pattern(ϕ::Factor, dims::Vector{Symbol})
    isempty(dims) && return Int[]

    _check_dims_valid(dims, ϕ)

    inds = indexin(dims, ϕ)
    len = length(ϕ)
    p = Array{Int}(len, length(dims))

    for i in 1:len
        t = ind2sub(ϕ, i)
        p[i, :] = [t[inds]...]
    end

    return p
end

function pattern(ϕ::Factor)
    sz = size(ϕ)

    len = length(ϕ)
    p = Array{Int}(len, ndims(ϕ))

    for i in 1:len
        p[i, :] = [ind2sub(sz, i)...]
    end

    return p
end

"""
    pattern_states(ϕ::Factor, [dim])

Returns the states of `dim`, given its current position in ϕ, for all possible states.
"""
pattern_states(ϕ::Factor, d::Symbol) = getdim(ϕ, d)[pattern(ϕ, d)]

function pattern_states(ϕ::Factor, dims::Vector{Symbol})
    isempty(dims) && return []

    pat = pattern(ϕ, dims)
    dims = getdim(ϕ, dims)

    return hcat([d[pat[:, i]] for (i, d) in enumerate(dims)]...)
end

function pattern_states(ϕ::Factor)
    pat = pattern(ϕ)

    return hcat([d[pat[:, i]] for (i, d) in enumerate(ϕ.dimensions)]...)
end
