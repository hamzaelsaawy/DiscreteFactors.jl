#
# Auxiliary Functions
#
# Not exactly related, but not exactly not

typealias Assignment Dict{Symbol, Any}

####################################################################################################
#                                   Dimensions

# make sure all the values are valid (in d)
_check_values_valid(v, d::Dimension) = (v in d) || not_in_dimension_error(v, d)

@inline function _check_values_valid(vs::AbstractArray, d::Dimension)
    for v in vs
        (v in d) || not_in_dimension_error(v, d)
    end
end

_check_assignment_singleton(i::Int, ::Symbol) = nothing
_check_assignment_singleton(::Array, name::Symbol) = nonsingleton_assignment_error(name)


####################################################################################################
#                                   Factors

# dims are unique
_check_dims_unique{D<:Dimension}(dims::Vector{D}) =
    (length(dims) == 0) || _check_dims_unique(map(name, dims))

_check_dims_unique(dims::Vector{Symbol}) = allunique(dims) || non_unique_dims_error()

# dimensions need at least 1 value
_check_dims_singleton(d::Dimension) = isempty(d) && empty_support_error(name(d))

@inline function _check_dims_singleton{D<:Dimension}(dims::Vector{D})
    for d in dims
        isempty(d) && empty_support_error(name(d))
    end
end

# make sure all dims are valid (in φ)
_check_dims_valid(d::Symbol, φ::Factor) = (d in φ) || not_in_factor_error(dim, φ)

@inline function _check_dims_valid(dims::Vector{Symbol}, ϕ::Factor)
    for d in dims
        (d in ϕ) || not_in_factor_error(d, φ)
    end
end

"""
    duplicate(A, dims)

Repeates an array only through higer dimensions `dims`.

Custom version of `Base.repeat`, but only outer repetition, and only duplicates
the array for the number of times specified in `dims` for dimensions greater
than `ndims(A)`. If `dims` is empty, returns a copy of `A`.

```jldoctest
julia> duplicate(collect(1:3), 2)
3×2 Array{Int64,2}:
 1  1
 2  2
 3  3

julia> duplicate([1 3; 2 4], 3)
2×2×3 Array{Int64,3}:
[:, :, 1] =
 1  3
 2  4

[:, :, 2] =
 1  3
 2  4

[:, :, 3] =
 1  3
 2  4
```
"""
function duplicate(A::Array, dims::Dims)
    size_in = size(A)

    length_in = length(A)
    size_out = (size_in..., dims...)::Dims

    B = similar(A, size_out)

    # zero in dims means no looping
    @simd for index in 1:prod(dims)
        unsafe_copy!(B, (index - 1) * length_in + 1, A, 1, length_in)
    end

    return B
end
