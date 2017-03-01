#
# Dealing with negatives
#
# Handles warnings, errors, or ignoring negative values

immutable NegativeMode{T} end

const NegativeWarn = NegativeMode{:warn}()
const NegativeError = NegativeMode{:error}()
const NegativeIgnore = NegativeMode{:ignore}()

# I know, this is a really bad idea
global _hneg = NegativeIgnore

function set_negative_mode(h::NegativeMode)
    global _hneg

    old_h, _hneg = _hneg, h

    return old_h
end

_check_negatives(ft::Factor) = _check_negatives(ft.potential)
_check_negatives(ft::Factor, h::NegativeMode) = _check_negatives(ft.potential, h)

_check_negatives{T<:Real}(p::Array{T}) = _check_negatives(p, _hneg)

_check_negatives(::Array, ::NegativeMode{:ignore}) = nothing

_check_negatives{T<:Real}(p::Array{T}, ::NegativeMode{:warn}) =
    any(p .< 0) && warn("potential has negative values")

# TODO find a better error type for this
_check_negatives{T<:Real}(p::Array{T}, ::NegativeMode{:error}) =
    any(p .< 0) && throw(ArgumentError("potential has negative values"))

_check_negatives(::Array, h::NegativeMode) = throw(ArgumentError("unkown handle type, " * repr(h)))
