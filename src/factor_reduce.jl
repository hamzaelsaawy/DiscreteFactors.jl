Base.sum{D<:Dimension, V<:Number}(ft::Factor{D, V}, dim::Symbol) =
    sum!(deepcopy(ft), dim)
Base.sum{D<:Dimension, V<:Number}(ft::Factor{D, V}, dims::Vector{Symbol}) =
    sum!(deepcopy(ft), dim)

function Base.sum!{D<:Dimension, V<:Number}(ft::Factor{D, V}, dim::Symbol)
    ind = findin(ft, dim)

    if ind == 0
        not_in_factor_error(dim)
    end

    ft.v = squeeze(sum(ft.v, ind), ind)
    deleteat!(ft.dimensions, ind)

    return ft
end

function Base.sum!{D<:Dimension, V<:Number}(ft::Factor{D, V}, dims::Vector{Symbol})
    inds = findin(ft, dims)
    # needs to be a tuple for squeeze
    inds = (inds...)

    zero_loc = findfirst(inds, 0)
    if zero_loc != 0
        not_in_factor_error(dims[zero_loc])
    end

    ft.v = squeeze(sum(ft.v, inds), inds)
    deleteat!(ft.dimensions, inds)

    return ft
end

