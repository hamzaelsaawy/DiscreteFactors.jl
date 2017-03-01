#
# Factors type and constructors
#
# Main code and basic functions for Factors

"""
    Factor(dims::AbstractVector{Dimension}, potential::Array{Real})
    Factor(dim::Dimension, potential::Vector{Real})
    Factor(dims::AbstractVector{Symbol}, potential::Array{Real})
    Factor(dim::Symbol, potential::Vector{Real})

Create a Factor with scope `dims` and potential `potential` (or a zero
potential).
"""
type Factor{N}
    dimensions::Vector{Dimension}
    # the value mapped to each instance
    potential::Array{Float64, N}

    function Factor{D<:Dimension}(dimensions::Vector{D}, potential::Array{Float64, N})
        _check_dims_unique(dimensions)
        _check_dims_singleton(dimensions)
        _check_negatives(potential)

        (length(dimensions) == N) || not_enough_dims_error()
        ([size(potential)...] == [length(d) for d in dimensions]) || invalid_dim_sizes()

        (:potential in map(name, dimensions)) &&
                warn("having a dimension called `potential` will cause problems")

        return new(dimensions, potential)
    end
end

####################################################################################################
#                                   Constructors

# because of type parametrics, Vector{Dimension} ~= D<:Dimension, Vector{D}
#  the latter will work more often than not

#                                   Default Constructors
# convert from ints and other reals to floats
Factor{D<:Dimension, V<:Real, N}(dims::Vector{D}, potential::Array{V, N}) =
        Factor{N}(collect(dims), float(potential))

# when it actually is floats, avoid (potential) overhead of float() call
Factor{D<:Dimension, N}(dims::Vector{D}, potential::Array{Float64, N}) =
        Factor{N}(collect(dims), potential)

Factor{V<:Real}(dim::Dimension, potential::Vector{V}) = Factor([dim], potential)

#                                   Default Value / Unitialized
"""
    Factor(dims::AbstractVector{Dims}, [value=0])

Create a factor with a potential initialized to `value`.
Use `value=nothing` for an unitialized potential
"""
function Factor{D<:Dimension}(dims::Vector{D}, value::Real=0)
    potential = fill(float(value), map(length, dims)...)

    return Factor(dims, potential)
end

function Factor{D<:Dimension}(dims::Vector{D}, ::Void)
    potential = Array{Float64}(map(length, dims)...)

    return Factor(dims, potential)
end

Factor(dim::Dimension, value::Real=0) = Factor([dim], value)

#                                   Symbols and Potential
Factor{V<:Real}(dim::Symbol, potential::Vector{V}) = Factor([dim], potential)

function Factor{V<:Real}(dims::Vector{Symbol}, potential::Array{V})
    (length(dims) == ndims(potential)) || not_enough_dims_error()
    new_dims = map(Dimension, dims, size(potential))

    return Factor(new_dims, potential)
end

#                                   Dictionary and Pairs
"""
    Factor(dims::Dict{Symbol}, [value=0])

    Factor([value=0], dims::Pair{Symbol}...)
    Factor(potential::Array{Real}, dims::Pair{Symbol}...)

Create factor from mappings from dimension names (symbols) to lengths,
ranges, or arrays.
"""
function Factor(dims::Dict{Symbol}, value=0)
    new_dims = [Dimension(name, state) for (name, state) in dims]

    return Factor(new_dims, value)
end

# this way, its order preserving ... if it matters
function Factor(potential, dims::Pair{Symbol}...)
    new_dims = [Dimension(n, a) for (n, a) in dims]

    return Factor(new_dims, potential)
end

function Factor(dims::Pair{Symbol}...)
    new_dims = [Dimension(n, a) for (n, a) in dims]

    return Factor(new_dims)
end

#                                   Zero Dimensional
"""
    Factor(potential::Real)

Create a zero-dimensional Factor.
"""
Factor(potential::Real) = Factor(Dimension[], squeeze(Float64[potential], 1))

#                                   Similar
Base.similar(ϕ::Factor) = Factor(scope(ϕ), nothing)

####################################################################################################
#                                   Methods

Base.eltype(::Factor) = Float64

"""
    names(ϕ::Factor)

Get an array of the names (symbols) of the dimensions of `ϕ`.
"""
Base.names(ϕ::Factor) = map(name, ϕ.dimensions)

"""
    potential(ϕ::Factor)

Get the potential of a Factor.
"""
potential(ϕ::Factor) = ϕ.potential

"""
    scope(ϕ)

Get the dimensions of `ϕ`.
"""
scope(ϕ::Factor) = ϕ.dimensions

Base.ndims{N}(::Factor{N}) = N

"""
    size(ϕ, [dims...])

Return a tuple of the dimensions of `ϕ`.
"""
Base.size(ϕ::Factor) = size(ϕ.potential)
Base.size(ϕ::Factor, dim::Symbol) = size(ϕ.potential, indexin(dim, ϕ))
Base.size{N}(ϕ::Factor, dims::Vararg{Symbol, N}) = ntuple(k -> size(ϕ, dims[k]), Val{N})

"""
    length(ϕ)

Return thelength of `ϕ`.
"""
Base.length(ϕ::Factor) = length(ϕ.potential)

"""
    in(d, ϕ::Factor)

Check if `Dimension` (or `Symbol`) `d` is in `ϕ`.
"""
Base.in(d::Dimension, ϕ::Factor) = d in scope(ϕ)
Base.in(d::Symbol, ϕ::Factor) = d in names(ϕ)

"""
    indexin(dims, ϕ::Factor)

Find the index of `dims` in `ϕ`. Return 0 if not in `ϕ`.
"""
Base.indexin(dim::Symbol, ϕ::Factor) = findnext(names(ϕ), dim, 1)
Base.indexin(dims::Vector{Symbol}, ϕ::Factor) = indexin(dims, names(ϕ))

Base.indexin(d::Dimension, ϕ::Factor) = findnext(scope(ϕ), dim, 1)
Base.indexin{D<:Dimension}(dims::AbstractVector{D}, ϕ::Factor) = indexin(dims, scope(ϕ))

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

"""
    push(ϕ::Factor, dim::Dimension)

Append a new dimension to a Factor
"""
function Base.push!(ϕ::Factor, dim::Dimension)
    (name(dim) in names(ϕ)) && error("Dimension $(name(dim)) already exists")

    ϕ.dimensions = push!(Vector{Dimension}(ϕ.dimensions), dim)
    ϕ.potential = duplicate(ϕ.potential, length(dim))

    return ϕ
end
