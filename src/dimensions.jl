singleton_dimension_error(l) = throw(
        ArgumentError("Dimension is singleton with length $(l)"))

non_unique_states_error() = throw(ArgumentError("States must be unique"))

abstract Dimension{T}

"""
A dimension whose states emnumerated in an array. Order does not matter
"""
immutable CardinalDimension{T} <: Dimension{T}
    name::Symbol
    states::AbstractArray{T, 1}

    function CardinalDimension(name::Symbol, states::AbstractArray{T, 1})
        if !allunique(states)
            non_unique_states_error()
        end

        if length(states) < 2
            singleton_dimension_error(length(states))
        end

        new(name, states)
    end
end

CardinalDimension{T}(name::Symbol, states::AbstractArray{T, 1}) =
   CardinalDimension{T}(name, states)

abstract AbstractOrdinalDimension{T} <: Dimension{T}

#support <, > comparisons, and an ordering in the states
immutable OrdinalDimension{T} <: AbstractOrdinalDimension{T}
    name::Symbol
    states::AbstractArray{T, 1}

    function OrdinalDimension(name::Symbol, states::AbstractArray{T, 1})
        if !allunique(states)
            non_unique_states_error()
        end

        if length(states) < 2
            singleton_dimension_error(length(states))
        end

        new(name, states)
    end
end

OrdinalDimension{T}(name::Symbol, states::AbstractArray{T, 1}) =
    OrdinalDimension{T}(name, states)


"""
Uses a Base.StepRange to enumerate possible states.

Starts at variable `start`, steps by `step`, ends at `stop` (or less,
if the math does't work out
"""
immutable OrdinalStepDimension{T, S} <: AbstractOrdinalDimension{T}
    name::Symbol
    states::StepRange{T, S}

    function OrdinalStepDimension(name::Symbol, start::T, step::S, stop::T)
        states = start:step:stop

        if length(states) < 2
            singleton_dimension_error(length(states))
        end

        new(name, states)
    end
end

OrdinalStepDimension{T,S}(name::Symbol, start::T, step::S, stop::T) =
    OrdinalStepDimension{T,S}(name, start, step, stop)

OrdinalStepDimension{T}(name::Symbol, start::T, stop::T) =
    OrdinalStepDimension{T,Int}(name, start, 1, stop)

"""
Similar to a UnitRange, enumerates values over start:stop
"""
immutable OrdinalUnitDimension{T} <: AbstractOrdinalDimension{T}
    name::Symbol
    states::UnitRange{T}

    function OrdinalUnitDimension(name::Symbol, start::T, stop::T)
        states = start:stop

        if length(states) < 2
            singleton_dimension_error(length(states))
        end

        new(name, states)
    end
end

OrdinalUnitDimension{T}(name::Symbol, start::T, stop::T) =
    OrdinalUnitDimension{T}(name, start, stop)

"""
An integer dimension that starts at 1

This is were the real magic happens, since all the optimizations will focus
on this one. If I optimize anything at all.
"""
immutable CartesianDimension{T<:Integer} <: AbstractOrdinalDimension{T}
    name::Symbol
    states::Base.OneTo{T}

    CartesianDimension(name::Symbol, length::T) = length < convert(T, 2) ?
        singleton_dimension_error(length) : new(name, Base.OneTo(length))
end

CartesianDimension{T<:Integer}(name::Symbol, length::T) =
    CartesianDimension{T}(name, length)

###############################################################################
#                   Functions

==(d1::Dimension, d2::Dimension) =
    (d1.name == d2.name) &&
    (length(d1.states) == length(d2.states)) &&
    all(d1.states .== d2.states)

Base.length(d::Dimension) = length(d.states)
Base.values(d::Dimension) = d.states
name(d::Dimension) = d.name

"""
Get the first state in this dimension
"""
function Base.first(d::Dimension)
    return first(d.states)
end

"""
Get the last state in this dimension
"""
function Base.last(d::Dimension)
    return last(d.states)
end

"""
Return the data type of the dimension
"""
function Base.eltype(d::Dimension)
    return typeof(first(d))
end

function Base.findin(d::Dimension, x)
    # states should all be unique
    return findfirst(d.states .== convert(eltype(d), x))
end

function .==(d::Dimension, x)
    # states should all be unique
    return d.states .== convert(eltype(d), x)
end

.!=(d::Dimension, x) = !(d .== x)

# can't be defined in terms of each b/c of
#  non-trivial case of x ∉ d
function .<(d::AbstractOrdinalDimension, x)
    ind = d .==  x
    loc = findfirst(ind)

    # if x is in the array
    if loc != 0
        ind[1:loc] = true
        ind[loc] = false
    else
        ind[:] = false
    end

    return ind
end

function .>(d::AbstractOrdinalDimension, x)
    ind = d .== x
    loc = findfirst(ind)

    # if x is in the array
    if loc != 0
        ind[loc:end] = true
        ind[loc] = false
    else
        ind[:] = false
    end

    return ind
end

function .<=(d::AbstractOrdinalDimension, x)
    ind = d .== x
    loc = findfirst(ind)
    ind[1:loc] = true

    return ind
end

function .>=(d::AbstractOrdinalDimension, x)
    ind = d .== x
    loc = findfirst(ind)
    ind[loc:end] = true

    return ind
end

function in(x, d::Dimension)
    return any(d.states .== convert(eltype(d), x))
end

###############################################################################
#                   IO Stuff

Base.mimewritable(::MIME"text/html", d::Dimension) = true

Base.show(io::IO, d::Dimension) =
    print(io, "$(d.name): $(repr(d.states)) ($(length(d)))")
Base.show(io::IO, a::MIME"text/html", d::Dimension) = show(io, d)

Base.show(io::IO, d::CartesianDimension) =
    print(io, "$(d.name): 1:$(last(d))")
Base.show(io::IO, a::MIME"text/html", d::CartesianDimension) = show(io, d)

