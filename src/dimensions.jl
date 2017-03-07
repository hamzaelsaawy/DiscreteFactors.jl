#
# Dimensions
#
# Main file for Dimension datatype

"""
    Dimension(name::Symbol, support::AbstractVector)

A dimesnion ... does what ???
"""
type Dimension{T<:AbstractVector} # {T, C<: AbstractVector{T}} <: AbstractVector{T} for Julia0.6
    name::Symbol
    support::T

    function Dimension(name::Symbol, support::T)
        isa(support, Range) || allunique(support) || non_unique_support_error()
        # now allowing empty dimensions :/
        #_check_singleton(support)

        new(name, support)
    end
end

Dimension{T<:AbstractVector}(name::Symbol, support::T) =
        Dimension{T}(name, support)

# promotion is automatic for arrays
Dimension(name::Symbol, support::Tuple) = Dimension(name, [support...])

# swap out unit ranges with OneTo
Dimension{V<:Integer}(name::Symbol, support::UnitRange{V}) =
        (first(support) == 1 && last(support) > 0) ?
                Dimension{Base.OneTo{V}}(name, Base.OneTo(length(support))) :
                Dimension{typeof(support)}(name, support)

"""
    Dimension(name::Symbol, length::Integer)

Create a dimension whose support ranges from `1` to `length`.
"""
Dimension(name::Symbol, length::Int) = Dimension(name, Base.OneTo(length))

typealias RangeDimension{T<:Range} Dimension{T}

####################################################################################################
#                                   Basic Functions

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

Base.isempty(d::Dimension) = d |> support |> isempty

Base.size(d::Dimension) = d |> support |> size

Base.first(d::Dimension) = d |> support |> first

Base.last(d::Dimension) = d |> support |> last

Base.minimum(d::Dimension) = d |> support |> minimum

Base.maximum(d::Dimension) = d |> support |> maximum

Base.step(d::RangeDimension) = d |> support |> step

Base.copy(d::Dimension) = d # dimensions are immutable

####################################################################################################
#                                   Iterating

Base.start(d::Dimension) = d |> support |> start

Base.next(d::Dimension, i) = next(support(d), i)

Base.done(d::Dimension, i) = done(support(d), i)

Base.eltype{T<:AbstractVector}(::Type{Dimension{T}}) = eltype(T)

"""
    spttype(::Type{Dimension})
    spttype(::Dimension)

Determine the type of the support. (E.g. `Vector{Char}` or `StepRange{Int64}`.)
"""
spttype{T<:AbstractVector}(::Type{Dimension{T}}) = T
spttype(d::Dimension) = spttype(typeof(d))

####################################################################################################
#                                   Indexing

Base.getindex(d::Dimension, I) = getindex(values(d), I)

Base.endof(d::Dimension) = endof(values(d))

# TODO profile this and see if its worthy
# custom indexin for integer (and float?) ranges
#@inline function Base.indexin(xs::AbstractVector, d::RangeDimension)
#    inds = zeros(Int, size(xs))
#
#    (ds, rs) = divrem(xs - first(d), step(d))
#    valid = (rs .== 0) & (minimum(d) .≤ xs .≤ maximum(d))
#    inds[valid] = abs(ds[valid]) + 1
#    inds == indexin(xs, d)
#
#    return inds
#end

Base.indexin(x, d::Dimension) = first(indexin([x], values(d)))

Base.indexin(xs::AbstractArray, d::Dimension) = indexin(xs, values(d))

"""
    update(d::Dimension, I)

Return the indicies of `I` in `d` and an updated dimension using `I`.

`I` is either an array of states found in `dm` or a logical index.
"""
@inline function update(d::Dimension, I)
    _check_values_valid(I, d)

    return _update(d, indexin(I, d))
end

update(d::Dimension, I::AbstractVector{Bool}) = _update(d, Base.to_index(I))
update(d::Dimension, ::Colon) = (:, d)

# given the index
_update(d::Dimension, ind::Int) = (ind, Dimension(name(d), []))
_update(d::Dimension, inds::Vector{Int}) = (inds, Dimension(name(d), d[inds]))

####################################################################################################
#                                   Comparisons and Equality

==(d1::Dimension, d2::Dimension) =
    (name(d1) == name(d2)) &&
    (length(d1) == length(d2)) &&
    all(support(d1) .== support(d2))

.==(d::Dimension, x) = values(d) .== x

.!=(d::Dimension, x) = !(d .== x)

# needed for indexin, union, etc..
hash(f::Dimension, h::UInt) = hash(f.name, h) + hash(f.support, h)
hash(f::Dimension) = hash(f, zero(UInt))

Base.in(x, d::Dimension) = in(x, values(d))

Base.findfirst(d::Dimension, x) = findfirst(values(d), x)

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
