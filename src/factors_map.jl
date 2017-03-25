#
# Factors Map
#
# log, abs, normalize, etc.

"""
    normalize(ϕ, dims; p=1)
    normalize(ϕ; p=1)

Return a normalized copy of the factor so all instances of dims have
(or the entire factors has) p-norm of 1. Only 1- and 2- norms are supported.
"""
LinAlg.normalize(ϕ::Factor, dims; p::Integer=1) = normalize!(deepcopy(ϕ), dims, p=p)
LinAlg.normalize(ϕ::Factor; p::Integer=1) = normalize!(deepcopy(ϕ), p=p)

"""
    normalize!(ϕ, dims; p=1)
    normalize!(ϕ; p=1)

Normalize the factor so all instances of dims have (or the entire factors has)
p-norm of 1. Only 1- and 2- norms are supported.
"""
LinAlg.normalize!(ϕ::Factor, dim::Symbol; p::Integer=1) = normalize!(ϕ, [dim], p=p)

function LinAlg.normalize!(ϕ::Factor, dims::Vector{Symbol}; p::Int=1)
    isempty(dims) && return ϕ
    _check_dims_valid(dims, ϕ)

    inds = indexin(dims, ϕ)
    ϕ.potential ./= _get_total(ϕ.potential, p, inds)
    
    return ϕ
end

function LinAlg.normalize!(ϕ::Factor; p::Integer=1)
    ϕ.potential ./= _get_total(ϕ.potential, p)

    return ϕ
end

# zero-dimensional gets weird ...  as always
function LinAlg.normalize!(ϕ::Factor{0}; p::Integer=1)
    ϕ.potential ./= first(_get_total(ϕ.potential, p))

    return ϕ
end

function _get_total{V<:Real, N}(A::Array{V, N}, p, r=(1:N))
    if p == 1
        total = sumabs(A, r)
    elseif p == 2
        total = sqrt(sumabs2(A, r))
    else
        throw(ArgumentError("p = $(p) is not supported"))
    end

    return total
end

"""
    map(f, ϕ::Factor)

Return a new Factor with `f` mapped over `ϕ.potential`.
"""
Base.map(f, ϕ::Factor) = Factor(deepcopy(scope(ϕ)), map(f, ϕ.potential))

"""
    map!(f, ϕ::Factor)

Map `f` over `ϕ.potential`.
"""
@inline function Base.map!(f, ϕ::Factor)
    map!(f, ϕ.potential)
    _check_negatives(ϕ)
    return ϕ
end

"""
    rand!(ϕ::Factor)

Fill `ϕ` with random values.
"""
@inline function Base.rand!(ϕ::Factor)
    rand!(ϕ.potential)
    _check_negatives(ϕ)
    return ϕ
end

"""
    rand!(ϕ::Factor)

Fill `ϕ` with random values from the standard normal.
"""
@inline function Base.randn!(ϕ::Factor)
    randn!(ϕ.potential)
    _check_negatives(ϕ)
    return ϕ
end

"""
    fill!(ϕ::Factor, x)

Fill `ϕ` with `x`.
"""
@inline function Base.fill!(ϕ::Factor, x)
    fill!(ϕ.potential, x)
    _check_negatives(ϕ)
    return ϕ
end

# shamelessly stolen from julia/base/deprecated.jl
for f in (:sin, :sinh, :sind, :asin, :asinh, :asind,
        :tan, :tanh, :tand, :atan, :atanh, :atand,
        :sinpi, :cosc, :ceil, :floor, :trunc, :round, :real, :imag,
        :log1p, :expm1, :abs, :abs2,
        :log, :log2, :log10, :exp, :exp2, :exp10, :sinc, :cospi,
        :cos, :cosh, :cosd, :acos, :acosd,
        :cot, :coth, :cotd, :acot, :acotd,
        :sec, :sech, :secd, :asech,
        :csc, :csch, :cscd, :acsch)
    q = parse("Base.$f")
    @eval ($q)(ϕ::Factor) = map($f, ϕ)
end
