#
# Dimensions
#
# Main file for Dimension datatype

abstract Dimension{T}

"""
    CardinalDimension(name, states)

A dimension whose states emnumerated in an array. Order does not matter
"""
immutable CardinalDimension{T} <: Dimension{T}
    name::Symbol
    states::AbstractVector{T}

    function CardinalDimension(name::Symbol, states::AbstractVector{T})
        allunique(states) || non_unique_states_error()
        length(states) > 1 || singleton_dimension_error(length(states))

        new(name, states)
    end
end

CardinalDimension{T}(name::Symbol, states::AbstractVector{T}) =
   CardinalDimension{T}(name, states)

# where order matters
abstract AbstractOrdinalDimension{T} <: Dimension{T}
# stored as a range
abstract AbstractRangeDimension{T} <: AbstractOrdinalDimension{T}

#support <, > comparisons, and an ordering in the states
immutable OrdinalDimension{T} <: AbstractOrdinalDimension{T}
    name::Symbol
    states::AbstractVector{T}

    function OrdinalDimension(name::Symbol, states::AbstractVector{T})
        allunique(states) || non_unique_states_error()
        length(states) > 1 || singleton_dimension_error(length(states))

        new(name, states)
    end
end

OrdinalDimension{T}(name::Symbol, states::AbstractVector{T}) =
    OrdinalDimension{T}(name, states)

"""
    OrdinalStepDimension(name::Symbol, states::StepRange{T, S})
    OrdinalStepDimension(name::Symbol, start::T, [step::S=1,] stop::T)

Uses a Base.StepRange to enumerate possible states.
"""
immutable StepDimension{T, S} <: AbstractRangeDimension{T}
    name::Symbol
    states::StepRange{T, S}

    function StepDimension(name::Symbol, states::StepRange{T, S})
        length(states) > 1 || singleton_dimension_error(length(states))

        new(name, states)
    end
end

StepDimension{T,S}(name::Symbol, states::StepRange{T, S}) =
    StepDimension{T,S}(name, states)

StepDimension{T,S}(name::Symbol, start::T, step::S, stop::T) =
    StepDimension{T,S}(name, start:step:stop)

StepDimension{T}(name::Symbol, start::T, stop::T) =
    StepDimension{T,Int}(name, start:1:stop)

"""
    OrdinalUnitDimension(name::Symbol, states:UnitRange{T})
    OrdinalUnitDimension(name::Symbol, start::T, stop::T)

Similar to a UnitRange, enumerates values over start:stop
"""
immutable UnitDimension{T<:Real} <: AbstractRangeDimension{T}
    name::Symbol
    states::UnitRange{T}

    function UnitDimension(name::Symbol, states::UnitRange{T})
        length(states) > 1 || singleton_dimension_error(length(states))

        new(name, states)
    end
end

UnitDimension{T<:Real}(name::Symbol, states::UnitRange{T}) =
    UnitDimension{T}(name, states)

UnitDimension{T<:Real}(name::Symbol, start::T, stop::T) =
    UnitDimension{T}(name, start:stop)

"""
    CartesianDimension(name::Symbol, states::Base.OneTo)
    CartesianDimension(name::Symbol, length)

An integer dimension that starts at 1.
"""
immutable CartesianDimension{T<:Integer} <: AbstractRangeDimension{T}
    name::Symbol
    states::OneTo{T}

    function CartesianDimension(name::Symbol, states::OneTo{T})
        length(states) > 1 || singleton_dimension_error(length(states))

        new(name, states)
    end
end

CartesianDimension{T<:Integer}(name::Symbol, states::OneTo{T}) =
    CartesianDimension{T}(name, states)

CartesianDimension{T<:Integer}(name::Symbol, length::T) =
    CartesianDimension{T}(name, OneTo(length))

###############################################################################
#                   Functions

name(d::Dimension) = d.name

Base.length(d::Dimension) = length(d.states)

Base.size(d::Dimension) = size(d.states)

Base.step(d::AbstractRangeDimension) = step(d.states)

Base.first(d::Dimension) = first(d.states)

Base.last(d::Dimension) = last(d.states)

minimum(d::Dimension) = minimum(d.states)

maximum(d::Dimension) = maximum(d.states)

Base.values(d::Dimension) = d.states

Base.eltype{T}(::Dimension{T}) = T

###############################################################################
#                   Indexing

# custom indexin for integer (and float?) ranges
function indexin{T<:Integer}(xs::Vector{T}, d::AbstractRangeDimension{T})
    inds = zeros(Int, size(xs))

    for (i, x) in enumerate(xs)
        if first(d) <= x <= last(d)
            (ind, rem) = divrem(x - first(d), step(d))
            if rem == 0
                inds[i] = ind + 1
            end
        end
    end

    return inds
end

indexin{T}(x::T, d::Dimension{T}) = first(indexin([x], d.states))

indexin{T}(xs::Vector{T}, d::Dimension{T}) = indexin(xs, d.states)

indexin{T}(r::Range{T}, d::Dimension{T}) = indexin(collect(r), d.states)

indexin{T}(::Colon, d::Dimension{T}) = collect(1:length(d))

###############################################################################
#                   Comparisons and Equality

# cardinal and ordinal dimensions are always unequal
==(::CardinalDimension, ::AbstractOrdinalDimension) = false

==(d1::CardinalDimension, d2::CardinalDimension) =
    (name(d1) == name(d2)) &&
    (length(d1.states) == length(d2.states)) &&
    all(values(d1) .== values(d2))

==(d1::AbstractOrdinalDimension, d2::AbstractOrdinalDimension) =
    (d1.name == d2.name) &&
    (length(d1.states) == length(d2.states)) &&
    all(values(d1) .== values(d2))

# states should all be unique
.==(d::Dimension, x) = d.states .== convert(eltype(d), x)

.!=(d::Dimension, x) = !(d .== x)

in(x, d::Dimension) = any(d .== x)

##                  specific to Ordinal dimensions

findfirst(d::AbstractOrdinalDimension, x) =
    findfirst(d.states, convert(eltype(d), x))

# can't be defined in terms of each b/c of non-trivial case of x ∉ d
@inline function .<(d::AbstractOrdinalDimension, x)
    ind = falses(length(d))
    loc = findfirst(d, x)

    # indexing works 1:-1 and 1:0 too ...
    ind[1:(loc - 1)] = true

    return ind
end

@inline function .>(d::AbstractOrdinalDimension, x)
    ind = falses(length(d))
    loc = findfirst(d, x)

    # if x ∉ d, then prevent 1:end being all true
    (loc != 0) && (ind[(loc + 1):end] = true)

    return ind
end

@inline function .<=(d::AbstractOrdinalDimension, x)
    ind = falses(length(d))
    loc = findfirst(d, x)

    ind[1:loc] = true

    return ind
end

@inline function .>=(d::AbstractOrdinalDimension, x)
    ind = falses(length(d))
    loc = findfirst(d, x)

    (loc != 0) && (ind[loc:end] = true)

    return ind
end

