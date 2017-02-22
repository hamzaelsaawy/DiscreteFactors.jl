#
# Factors Iteration
#
# Iterating over indices, potential, etc.

"""
    pattern(φ::Factor, [dim])

Return the index of the states of `dim`, given its current position in φ.
"""
pattern(φ::Factor, dim::Symbol) = pattern(φ, [dim])
function pattern(φ::Factor, dims::Vector{Symbol})
    _check_dims_valid(dims, φ)

    inds = indexin(dims, φ)
    lens = Int[size(φ)...]

    inners = vcat(1, cumprod(lens[1:(end-1)]))
    outers = Vector{Int}(length(φ) ./ lens[inds] ./ inners[inds])

    hcat([repeat(Vector(1:length(d)), inner=i, outer=o) for (d, i, o) in
            zip(φ.dimensions[inds], inners[inds], outers)]...)
end

function pattern(φ::Factor)
    lens = Int[size(φ)...]

    inners = vcat(1, cumprod(lens[1:(end-1)]))
    outers = Vector{Int}(length(φ) ./ lens ./ inners)

    hcat([repeat(Vector(1:length(d)), inner=i, outer=o) for (d, i, o) in
            zip(φ.dimensions, inners, outers)]...)
end

"""
    pattern_states(φ::Factor, [dim])

Returns the states of `dim`, given its current position in φ.
"""
pattern_states(φ::Factor, dim::Symbol) =
    getdim(φ, dim)[pattern(φ, dims)]

function pattern_states(φ::Factor, dims::Vector{Symbol})
    dims = getdim(φ, dims)
    pat = pattern(φ, dims)

    return hcat([d[pat[:, i]] for (i, d) in enumerate(dims)]...)
end

function pattern_states(φ::Factor)
    pat = pattern(φ)

    return hcat([d[pat[:, i]] for (i, d) in enumerate(φ.dimensions)]...)
end

