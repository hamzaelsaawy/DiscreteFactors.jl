#
# Factors Map
#
# log, abs, normalize, etc.

"""
    normalize!(ϕ, dims; p=1)
    normalize!(ϕ; p=1)

Return a normalized copy of the factor so all instances of dims have
(or the entire factors has) p-norm of 1
"""
LinAlg.normalize(ϕ::Factor, x...; p::Integer=1) = normalize!(deepcopy(ϕ), x...; p)

"""
    normalize!(ϕ, dims; p=1)
    normalize!(ϕ; p=1)

Normalize the factor so all instances of dims have (or the entire factors has)
p-norm of 1
"""
LinAlg.normalize!(ϕ::Factor, dim::Symbol; p::Integer=1) = normalize!(ϕ, [dim], p)

function LinAlg.normalize!(ϕ::Factor, dims::Vector{Symbol}; p::Int=1)
    _check_dims_valid(dims, ϕ)
    isempty(dims) && return ϕ

    inds = indexin(dims, ϕ)

    if p == 1
        total = sumabs(ϕ.potential, inds)
    elseif p == 2
        total = sumabs2(ϕ.potential, inds)
    else
        throw(ArgumentError("p = $(p) is not supported"))
    end

    ϕ.potential ./= total
    return ϕ
end

function LinAlg.normalize!(ϕ::Factor; p::Integer=1)
    if p == 1
        total = sumabs(ϕ.potential)
    elseif p == 2
        total = sumabs2(ϕ.potential)
    else
        throw(ArgumentError("p = $(p) is not supported"))
    end

    ϕ.potential ./= total

    return ϕ
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
@inline function fill!(ϕ::Factor, x)
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
