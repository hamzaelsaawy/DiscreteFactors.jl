abstract Dimension{T}

singleton_dimension(l) = error("Dimension is singleton with length $(l)")

"""
A dimension whose states emnumerated in an array. Order does not matter
"""
immutable CardinalDimension{T} <: Dimension{T}
    name::Symbol
    states::AbstractArray{T, 1}

    function CardinalDimension(name::Symbol, states)
        if length(unique(states)) != length(states)
            error("States must be unique")
        end

        if length(states) < 2
            singleton_dimension(length(states))
        end

        new(name, states)
    end
end

# I need to figure this parametric stuff out
CardinalDimension{T}(name::Symbol, states::AbstractArray{T, 1}) =
   CardinalDimension{T}(name, states)

"""
Uses a Base.StepRange to enumerate possible states.

Starts at variable `start`, steps by `step`, ends at `stop` (or less,
if the math does't work out
"""
immutable OrdinalStepDimension{T, S} <: Dimension{T}
    name::Symbol
    states::StepRange{T, S}

    function OrdinalStepDimension(name::Symbol, start::T, step::S, stop::T)
        states = start:step:stop

        if length(states) < 2
            singleton_dimension(length(states))
        end

        new(name, states)
    end
end

OrdinalStepDimension{T,S}(name::Symbol, start::T, step::S, stop::T) =
    OrdinalStepDimension{T,S}(name, start, step, stop)

"""
Similar to a UnitRange, enumerates values over start:stop
"""
immutable OrdinalUnitDimension{T} <: Dimension{T}
    name::Symbol
    states::UnitRange{T}

    function OrdinalUnitDimension(name::Symbol, start::T, stop::T)
        states = start:stop

        if length(states) < 2
            singleton_dimension(length(states))
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
immutable CartesianDimension <: Dimension{Signed}
    name::Symbol
    length::Int

    CartesianDimension(name::Symbol, length::Int) = length < 2 ?
        singleton_dimension(length) : new(name, length)
end

# all the dimensions that have a variable called states
typealias StatefulDimension
    Union{CardinalDimension, OrdinalUnitDimension, OrdinalStepDimension}

###############################################################################
#                   Functions

Base.length(d::StatefulDimension) = length(d.states)
Base.length(d::CartesianDimension) = d.length

Base.values(d::StatefulDimension) = d.states
Base.values(d::CartesianDimension) = 1:d.length

name(d::Dimension) = d.name

function Base.findin(d::CardinalDimension, x)
    i = findin(d.states, x)

    # states should all be unique
    return isempty(i) ? 0 : i[1]
end

function Base.findin(d::CartesianDimension, x)
    return (x < 1 || x > d.length) ?  0 : x
end

###############################################################################
#                   IO Stuff

Base.mimewritable(::MIME"text/html", d::Dimension) = true

Base.show(io::IO, d::StatefulDimension) =
    println(io, "Dimension $(d.name): $(repr(d.states))")
Base.show(io::IO, a::MIME"text/html", d::StatefulDimension) = show(io, d)

Base.show(io::IO, d::CartesianDimension) =
    println(io, "Dimension $(d.name): 1:$(d.length)")
Base.show(io::IO, a::MIME"text/html", d::CartesianDimension) = show(io, d)

