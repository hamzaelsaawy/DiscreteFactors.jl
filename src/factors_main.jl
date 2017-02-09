#
# Factors type and constructors
#
# Main code and basic functions for Factors

"""
    Factor(dims, potential)

Create a Factor corresponding to the potential.
"""
type Factor{D<:Dimension}
    dimensions::Vector{D}
    # the value mapped to each instance
    potential::Array{Float64}

    function Factor(dimensions::Vector{D}, potential::Array)
        _check_dims_unique(dimensions)

        (length(dimensions) == ndims(potential)) || not_enough_dims_error()

        ([size(potential)...] == [length(d) for d in dimensions]) ||
                invalid_dim_sizes()

        (:potential in map(name, dimensions)) &&
            warn("having a dimension called `potential` will cause problems")

        return new(dimensions, potential)
    end
end

# convert from ints and other reals to floats
Factor{D<:Dimension, V<:Real}(dims::Vector{D}, potential::Array{V}) =
    Factor{D}(dims, float(potential))

# when it actually is floats, avoid (potential) overhead of float() call
Factor{D<:Dimension}(dims::Vector{D}, potential::Array{Float64}) =
    Factor{D}(dims, potential)

Factor{V<:Real}(dimension::Dimension, potential::Vector{V}) =
    Factor([dim], potential)

# just dimensions, create zero potential
Factor(dim::Dimension) = Factor([dim])
function Factor{D<:Dimension}(dims::Vector{D})
    potential = zeros(Float64, [length(d) for d in dims]...)

    return Factor(dims, potential)
end

# symbol names and potential
Factor{V<:Real}(dim::Symbol, potential::Vector{V}) =
    Factor([dim], potential)

function Factor{V<:Real}(dims::Vector{Symbol}, potential::Array{V})
    (length(dims) == ndims(potential)) || not_enough_dims_error()
    new_dims = map(CartesianDimension, dims, size(potential))

    return Factor(new_dims, potential)
end

"""
    Factor(dims::Dict{Symbol, Any})
    Factor(dims::Pair{Symbol, Any}...)

Create factor from mappings from dimension names (symbols) to lengths,
ranges, or arrays.

Use dimension(::Symbol, ::Any) to create a Dimension from each pair.
"""
function Factor(dims::Dict{Symbol, Any})
    new_dims = [CartesianDimension(name, state) for (name, state) in dims]
    Factor(new_dims)
end

Factor(dims::Pair{Symbol, Any}...) = Factor(Dict(dims))

###############################################################################
#                   Methods

Base.eltype(::Factor) = Float64

"""
    names(φ::Factor)

Get an array of the names of each dimension in `φ`.
"""
Base.names(φ::Factor) = map(name, φ.dimensions)

Base.ndims(φ::Factor) = ndims(φ.potential)

"""
    size(φ, [dims...])

Return a tuple of the dimensions of `φ`.
"""
Base.size(φ::Factor) = size(φ.potential)
Base.size(φ::Factor, dim::Symbol) = size(φ.potential, indexin(dim, φ))
Base.size{N}(φ::Factor, dims::Vararg{Symbol, N}) =
    ntuple(k -> size(φ, dims[k]), Val{N})

Base.length(φ::Factor) = length(φ.potential)
Base.length(φ::Factor, dim::Symbol) = length(getdim(φ, dim))
Base.length(φ::Factor, dims::Vector{Symbol}) = [length(φ, dim) for dim in dims]

"""
    indexin(dims, φ::Factor)

Find index of dimension `dims` in `φ`. Return 0 if not in `φ`.
"""
Base.indexin(dim::Symbol, φ::Factor) = findnext(names(φ), dim, 1)
Base.indexin(dims::Vector{Symbol}, φ::Factor) = indexin(dims, names(φ))

"""
    getdim(φ::Factor, dim::Symbol)
    getdim(φ::Factor, dims::Vector{Symbol})

Get the dimension with name `dim` in `φ`.
"""
@inline function getdim(φ::Factor, dim::Symbol)
    i = indexin(dim, φ)

    (i == 0) && not_in_factor_error(dim)

    return φ.dimensions[i]
end

@inline function getdim(φ::Factor, dims::Vector{Symbol})
    _check_dims_valid(dims, φ)

    inds = indexin(dims, φ)
    return φ.dimensions[inds]
end

"""
    pattern(φ::Factor, dim)

Return the index of the states of `dim`, given its current position in φ.
"""
function pattern(φ::Factor, dim::Symbol)
    ind = indexin(dim, φ)
    lens = size(φ)

    (ind == 0) && not_in_factor_error(dim)

    inner = prod(lens[1:(ind-1)])
    outer = Int(length(φ) / inner / lens[ind])

    repeat(Vector(1:length(φ.dimensions[ind])), inner=inner, outer=outer)
end

function pattern(φ::Factor, dims::Vector{Symbol})
    _check_dims_valid(dims, φ)

    inds = indexin(dims, φ)
    lens = size(φ)

    inners = vcat(1, cumprod(lens[1:(end-1)]))
    outers = Vector{Int}(length(φ) ./ lens[inds] ./ inners[inds])

    hcat([repeat(Vector(1:length(d)), inner=i, outer=o) for (d, i, o) in
            zip(φ.dimensions[inds], inners[inds], outers)]...)
end

function pattern(φ::Factor)
    lens = lengths(φ)

    inners = vcat(1, cumprod(lens[1:(end-1)]))
    outers = Vector{Int}(length(φ) ./ lens ./ inners)

    hcat([repeat(Vector(1:length(d)), inner=i, outer=o) for (d, i, o) in
            zip(φ.dimensions, inners, outers)]...)
end

"""
    pattern_states(φ::Factor, dim)

Returns the states of `dim`, given its current position in φ.
"""
pattern_states(φ::Factor, dim::Symbol) =
    getdim(φ, dim).states[pattern(φ, dims)]

function pattern_states(φ::Factor, dims::Vector{Symbol})
    dims = getdim(φ, dims)
    return hcat([d.states[pattern(φ, d.name)] for d in dims]...)
end

pattern_states(φ::Factor) =
    hcat([d.states[pattern(φ, d.name)] for d in φ.dimensions]...)

"""
Appends a new dimension to a Factor
"""
function Base.push!(φ::Factor, dim::Dimension)
    if name(dim) in names(φ)
        error("Dimension $(name(dim)) already exists")
    end

    φ.dimensions = push!(Vector{Dimension}(φ.dimensions), dim)
    φ.potential = duplicate(φ.potential, length(dim))

    return φ
end

function Base.permutedims!(φ::Factor, perm)
    φ.potential = permutedims(φ.potential, perm)
    φ.dimensions = φ.dimensions[perm]

    return φ
end

Base.permutedims(φ::Factor, perm) = permutedims!(deepcopy(φ), perm)

