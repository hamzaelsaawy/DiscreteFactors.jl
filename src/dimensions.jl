#
# Dimensions
#
# Main file for Dimension datatype

"""
    Dimension(name::Symbol, support::AbstractVector)

A dimesnion ... does what ???
"""
type Dimension{T<:AbstractArray} # <: AbstractVector
    name::Symbol
    support::T

    function Dimension(name::Symbol, support::T)
        allunique(support) || non_unique_support_error()
        _check_singleton(support)

        new_support = promote(support...)
        new(name, new_support)
    end
end

Dimension{T}(name::Symbol, support::AbstractVector{T}) =
    Dimension{T}(name, support)

Dimension(name::Symbol, support::Tuple) =
    Dimension(name, [promote(support)...])

# swap out unit ranges with OneTo
Dimension{T}(name::Symbol, support::UnitRange{T<:Integer}) =
    (first(support) == 1 && last(support) > 0) ?
        Dimension(name, Base.OneTo(length(support)) :
        Dimension(name, support)

"""
    Dimension(name::Symbol, length::Integer)

Create a dimension whose support ranges from `1` to `length`.
"""
Dimension(name::Symbol, length::Int) =
    Dimension(name, Base.OneTo(length))

typealias RangeDimension <: Dimension{T<:Range}

###############################################################################
#                   Basic Functions

# genaric name and value
"""
    name(d::Dimension)

Return the name of the dimension, as a symbol
"""
name(d::Dimension) = d.name

"""
    values(d::Dimension)

Return the possible values a dimension can take.
"""
Base.values(d::Dimension) = d.support

"""
    support(d::Dimension)

Return the possible values a dimension can take.
"""
support(d::Dimension) = d |> values

Base.length(d::Dimension) = d |> support |> length

Base.size(d::Dimension) = d |> support |> size

Base.first(d::Dimension) = d |> support |> first

Base.last(d::Dimension) = d |> support |> last

minimum(d::Dimension) = d |> support |> minimum

maximum(d::Dimension) = d |> support |> maximum

Base.step(d::RangeDimension) = d |> support |> step


###############################################################################
#                   Iterating

Base.start(d::Dimension) = d |> support |> start

Base.next(d::Dimension, i) = d |> support |> next

Base.done(d::Dimension, i) = d |> support |> done

Base.eltype(d::Dimension{T}) = d |> support |> eltype

###############################################################################
#                   Indexing

Base.getindex(d::Dimension, I) = getindex(values(d), I)

Base.endof(d::Dimension) = endof(values(d))

# custom indexin for integer (and float?) ranges
# TODO profile this and see if its worthy
#@inline function indexin(xs::AbstractVector, d::RangeDimension)
#    inds = zeros(Int, size(xs))
#
#    (ds, rs) = divrem(xs - first(d), step(d))
#    valid = (rs .== 0) & (minimum(d) .≤ xs .≤ maximum(d))
#    inds[valid] = abs(ds[valid]) + 1
#    inds == indexin(xs, d)
#
#    return inds
#end

indexin(x, d::Dimension) = first(indexin([x], values(d)))

indexin(xs::AbstractArray, d::Dimension) = indexin(xs, values(d))

"""
    update(dim::Dimension, I)

Return the indicies of `I` in `dim` and  an updated dimension from `I`

`I` is either an array of states found in `dim` or a logical index.
"""
update(d::Dimension, I) = _update(dim, indexin(I, d))

update(d::Dimension, I::AbstractVector{Bool}) = _update(d, find(I))

# given the index
_update(d::Dimension, ind::Int) = (ind, nothing)
function _update(d::Dimension, inds::Vector{Int})
    vs = d[inds]
    new_d = Dimension(name(d), vs)

    return(inds, new_d)
end

###############################################################################
#                   Comparisons and Equality

==(d1::Dimension, d2::Dimension) =
    (name(d1) == name(d2)) &&
    (length(d1) == length(d2) &&
    (d1 == d2)

.==(d::Dimension, x) = values(d) .== x

.!=(d::Dimension, x) = !(d .== x)

in(x, d::Dimension) = any(d .== x)

findfirst(d::Dimension, x) = findfirst(values(d), x)

# can't be defined in terms of each b/c of non-trivial case of x ∉ d
@inline function .<(d::Dimension, x)
    ind = falses(length(d))
    loc = findfirst(d, x)

    # indexing works 1:-1 and 1:0 too ...
    ind[1:(loc - 1)] = true

    return ind
end

@inline function .>(d::Dimension, x)
    ind = falses(length(d))
    loc = findfirst(d, x)

    # if x ∉ d, then prevent 1:end being all true
    (loc != 0) && (ind[(loc + 1):end] = true)

    return ind
end

@inline function .<=(d::Dimension, x)
    ind = falses(length(d))
    loc = findfirst(d, x)

    ind[1:loc] = true

    return ind
end

@inline function .>=(d::Dimension, x)
    ind = falses(length(d))
    loc = findfirst(d, x)

    (loc != 0) && (ind[loc:end] = true)

    return ind
end

