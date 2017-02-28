#
# Factors Iteration
#
# Iterating over indices, potential, etc.

"""
    pattern(ϕ::Factor, [dim])

Return the index of the states of `dim`, given its current position in ϕ.
"""
pattern(ϕ::Factor, dim::Symbol) = pattern(ϕ, [dim])

function pattern(ϕ::Factor, dims::Vector{Symbol})
    _check_dims_valid(dims, ϕ)

    inds = indexin(dims, ϕ)
    lens = Int[size(ϕ)...]

    inners = vcat(1, cumprod(lens[1:(end-1)]))
    outers = Vector{Int}(length(ϕ) ./ lens[inds] ./ inners[inds])

    return hcat([repeat(Vector(1:length(d)), inner=i, outer=o) for (d, i, o) in
            zip(ϕ.dimensions[inds], inners[inds], outers)]...)
end

function pattern(ϕ::Factor)
    lens = Int[size(ϕ)...]

    inners = vcat(1, cumprod(lens[1:(end-1)]))
    outers = Vector{Int}(length(ϕ) ./ lens ./ inners)

    return hcat([repeat(Vector(1:length(d)), inner=i, outer=o) for (d, i, o) in
            zip(ϕ.dimensions, inners, outers)]...)
end

"""
    pattern_states(ϕ::Factor, [dim])

Returns the states of `dim`, given its current position in ϕ.
"""
pattern_states(ϕ::Factor, dim::Symbol) = getdim(ϕ, dim)[pattern(ϕ, dims)]

function pattern_states(ϕ::Factor, dims::Vector{Symbol})
    dims = getdim(ϕ, dims)
    pat = pattern(ϕ, dims)

    return hcat([d[pat[:, i]] for (i, d) in enumerate(dims)]...)
end

function pattern_states(ϕ::Factor)
    pat = pattern(ϕ)

    return hcat([d[pat[:, i]] for (i, d) in enumerate(ϕ.dimensions)]...)
end
