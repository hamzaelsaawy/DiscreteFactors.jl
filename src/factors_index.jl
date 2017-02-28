#
# Factors Indexing
#
# For ft[:A] syntax and such

# Column access (ft[:A]) returns the dimension for comparisons and stuff
Base.getindex(ft::Factor, dim::Symbol) = getdim(ft, dim)
Base.getindex(ft::Factor, dims::Vector{Symbol}) = getdim(ft, dims)

# TODO setindex for ft[dim]
# TODO (:X => ...) to (5, ...)
# TODO ft[:X=> ...]
# TODO ft[:]

# Index by number gets that ind
#Base.getindex(ft::Factor, i::Int) = ft.v[i]
#Base.getindex(ft::Factor, I::Vararg{Int}) = ft.v[I]

function Base.getindex(ft::Factor, Is::Pair{Symbol}...)
    
end

function Base.getindex(ft::Factor, a::Assignment)
    return ft.v[_translate_index(ft, a)...]
end

function Base.setindex!(ft::Factor, v, a::Assignment)
    return ft.v[_translate_index(ft, a)...] = v
end

function _translate_index(ft::Factor, a::Assignment)
    ind = Array{Any}(ndims(ft))
    # all dimensions are accessed by default
    ind[:] = Colon()

    for (i, dim) in enumerate(ft.dimensions)
        if haskey(a, dim.name)
            val = a[dim.name]

            if isa(val, BitArray)
                length(dim) == length(val) || throw(ArgumentError("Length " *
                            "of BitArray does not match dimension $(dim.name)"))
                ind[i] = val
            else
                # index in each dimension is location of value
                ind[i] = indexin(val, dim)

                if any(ind[i] .== 0)
                    # if assignment[d] is not valid,shortcircuit and
                    #  return an empty array
                    return []
                end
            end
        end
    end

    return ind
end


Base.sub2ind(ft::Factor, i...) = sub2ind(size(ft), i...)
Base.ind2sub(ft::Factor, i) = ind2sub(size(ft), i)
