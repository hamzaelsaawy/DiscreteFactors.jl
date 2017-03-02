#
# Factors mappings
#
# log, abs, normalize, etc.

"""
    normalize!(ϕ, dims; p=1)
    normalize!(ϕ; p=1)

Return a normalized copy of the factor so all instances of dims have
(or the entire factors has) p-norm of 1
"""
LinAlg.normalize(ϕ::Factor, x...; k...) = normalize!(deepcopy(ϕ), x...; k...)

"""
    normalize!(ϕ, dims; p=1)
    normalize!(ϕ; p=1)

Normalize the factor so all instances of dims have (or the entire factors has)
p-norm of 1
"""
function LinAlg.normalize!(ϕ::Factor, dims::NodeNameUnion; p::Int=1)
    dims = unique(convert(NodeNames, dims))
    _check_dims_valid(dims, ϕ)

    inds = indexin(dims, ϕ)

    if !isempty(inds)
        if p == 1
            total = sumabs(ϕ.potential, inds)
        elseif p == 2
            total = sumabs2(ϕ.potential, inds)
        else
            throw(ArgumentError("p = $(p) is not supported"))
        end

        ϕ.potential ./= total
    end

    return ϕ
end

function LinAlg.normalize!(ϕ::Factor; p::Int=1)
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
