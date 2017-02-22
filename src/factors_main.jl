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

        _check_negatives(potential)

        return new(dimensions, potential)
    end
end

#                   Default Outer Constructors
# convert from ints and other reals to floats
Factor{D<:Dimension, V<:Real}(dims::AbstractVector{D},
        potential::AbstractArray{V}) =
    Factor{D}(collect(dims), float(potential))

# when it actually is floats, avoid (potential) overhead of float() call
Factor{D<:Dimension}(dims::AbstractVector{D},
        potential::AbstractArray{Float64}) =
    Factor{D}(collect(dims), potential)

Factor{V<:Real}(dim::Dimension, potential::AbstractVector{V}) =
    Factor([dim], potential)

#                   Symbols and Potential
# symbol names and potential
Factor{V<:Real}(dim::Symbol, potential::AbstractVector{V}) =
    Factor([dim], potential)

function Factor{V<:Real}(dims::AbstractVector{Symbol}, potential::Array{V})
    (length(dims) == ndims(potential)) || not_enough_dims_error()
    new_dims = map(Dimension, dims, size(potential))

    return Factor(new_dims, potential)
end

"""
    Factor(dims::AbstractVector{Dims}, [value=0])

Create a factor with a potential initialized to `value`.
Use `value=nothing` for an unitialized potential
"""
function Factor{D<:Dimension}(dims::AbstractVector{D}, value::Real=0)
    potential = fill(float(value), map(length, dims)...)

    return Factor(dims, potential)
end

function Factor{D<:Dimension}(dims::AbstractVector{D}, ::Void)
    potential = Array{Float64}(map(length, dims)...)

    return Factor(dims, potential)
end

Factor(dim::Dimension, value::Real=0) = Factor([dim], value)

"""
    Factor(dims::Dict{Symbol})
    Factor(dims::Pair{Symbol}...)
    Factor(potential::Array{Real}, dims::Pair{Symbol}...)

Create factor from mappings from dimension names (symbols) to lengths,
ranges, or arrays.
"""
function Factor(dims::Dict{Symbol})
    new_dims = [Dimension(name, state) for (name, state) in dims]
    Factor(new_dims)
end

# this way, its order preserving ... if it matters
function Factor(dims::Pair{Symbol}...)
    new_dims = [Dimension(n, a) for (n, a) in dims]
    Factor(new_dims)
end

function Factor{V<:Real}(potential::AbstractArray{V}, dims::Pair{Symbol}...)
    new_dims = [Dimension(n, a) for (n, a) in dims]
    Factor(new_dims, potential)
end

"""
    Factor(potential::Real)

Create a zero-dimensional Factor.
"""
Factor(potential::Real) = Factor(Dimension[], squeeze(Float64[potential], 1))

###############################################################################
#                   Methods

Base.eltype(::Factor) = Float64

"""
    names(φ::Factor)

Get an array of the names of the dimensions of `φ`.
"""
Base.names(φ::Factor) = map(name, φ.dimensions)

"""
    scope(φ)

Get the dimensions of `φ`.
"""
scope(φ::Factor) = φ.dimensions

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

