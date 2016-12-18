#
# Factors Code
#
# Main file for Factors

typealias Assignment Dict{Symbol, Any}

type Factor{D<:Dimension, V}
    dimensions::Vector{D}
    # the value mapped to each instance
    v::Array{V}

    function Factor(dimensions::Vector{D}, v::Array{V})
        if length(dimensions) != ndims(v)
            throw(ArgumentError("v must have as many dimensions as dimensions"))
        end

        if [size(v)...] != [length(d) for d in dimensions]
            throw(ArgumentError("Number of states must match values size"))
        end

        if !allunique(map(name, dimensions))
            non_unique_dims_error()
        end

        if :v in map(name, dimensions)
            warn("having a dimension called `v` will cause problems")
        end

        return new(dimensions, v)
    end
end

Factor(eltype=Float64) =
    Factor{Dimension, eltype}(Dimension[], squeeze(zeros(eltype, 1), 1))

Factor{D<:Dimension, V}(dimensions::Vector{D}, v::Array{V}) =
    Factor{D, V}(dimensions, v)

Factor{V}(dimension::Dimension, v::Vector{V}) =
    Factor{typeof(dimension), V}([dimension], v)

function Factor{D<:Dimension}(dimensions::Vector{D}, eltype=Float64)
    v = zeros(eltype, [length(d) for d in dimensions]...)
    Factor{D, eltype}(dimensions, v)
end

function Factor(d::Dimension, eltype=Float64)
    v = zeros(eltype, length(d))
    Factor{typeof(d), eltype}([d], v)
end

"""
Initialize with a dictionary mapping dimension names (symbols) to their lenghts

V will be a zero matrix with type eltype
"""
function Factor{T<:Integer}(d::Dict{Symbol, T}, eltype)
    dimensions = [CartesianDimension(x...) for x in d]
    Factor(dimensions, eltype)
end

"""
Initialize with dimension names, a list of thier lengths, and type of v

V will be a zero matrix with type eltype
"""
function Factor{T<:Integer}(dims::Vector{Symbol}, lens::Vector{T}, eltype)
    if length(dims) != length(dims)
        throw(ArgumentError("Number of dimensions and lengths do not match"))
    end

    dimensions = [CartesianDimension(x...) for x in zip(dims, lens)]
    Factor(dimensions, eltype)
end

"""
Initialize with a vector of dimension names and a value array
"""
function Factor{V}(dims::Vector{Symbol}, v::Array{V})
    if length(dims) != ndims(v)
        throw(ArgumentError(
                    "Number of dimensions and dimensions of v do not match"))
    end

    dimensions = [CartesianDimension(x...) for x in zip(dims, size(v))]
    Factor(dimensions, v)
end

###############################################################################
#                   Methods

"""
Returns tuple of the type of Dimensions and the value mapping, v
"""
Base.eltype(ft::Factor) = (eltype(ft.dimensions), eltype(ft.v))
"""
Names of each dimension
"""
Base.names(ft::Factor) = map(name, ft.dimensions)

Base.ndims(ft::Factor) = ndims(ft.v)

"""
Returns the number of states in each dimension as a tuple
"""
Base.size(ft::Factor) = size(ft.v)

"""
Same as size, but as a vector instead of a tuple
"""
lengths(ft::Factor) = [size(ft)...]

"""
Total number of elements in the value mapping, v
"""
Base.length(ft::Factor) = length(ft.v)
Base.length(ft::Factor, dim::Symbol) = length(getdim(ft, dim))
Base.length(ft::Factor, dims::Vector{Symbol}) =
    [length(ft, dim) for dim in dims]

Base.sub2ind(ft::Factor, i...) = sub2ind(size(ft), i...)
Base.ind2sub(ft::Factor, i) = ind2sub(size(ft), i)


"""
Returns the index of dimension `dims` in `ft`. Returns 0 if not in `ft`.
"""
function Base.indexin(ft::Factor, dims)
    if isa(dims, Symbol)
        return indexin([dims], names(ft))[1]
    elseif isa(dims, Vector{Symbol})
        return indexin(dims, names(ft))
    elseif isa(dims, Dimension)
        return indexin([dims], ft.dimensions)[1]
    elseif isa(dims, Vector{Dimension})
        return indexin(dims, ft.dimensions)
    else
        throw(ArgumentError("Unsupported argument type: $typeof(dims)"))
    end
end

function getdim(ft::Factor, dim::Symbol)
    i = indexin(ft, dim)

    if i == 0
        not_in_factor_error(dim)
    end

    return ft.dimensions[i]
end

function getdim(ft::Factor, dims::Vector{Symbol})
    inds = indexin(ft, dims)

    zero_loc = findfirst(inds, 0)
    if zero_loc != 0
        not_in_factor_error(dims[zero_loc])
    end

    return ft.dimensions[inds]
end

"""
Returns the pattern of `dim` without the states
"""
function pattern(ft::Factor, dim::Symbol)
    ind = indexin(ft, dim)

    if ind == 0
        not_in_factor_error(dim)
    end

    lens = lengths(ft)


    inner = prod(lens[1:(ind-1)])
    outer = Int(length(ft) / inner / lens[ind])

    repeat(Vector(1:length(ft.dimensions[ind])), inner=inner, outer=outer)
end

function pattern(ft::Factor, dims::Vector{Symbol})
    inds = indexin(ft, dims)

    zero_loc = findfirst(inds, 0)
    if zero_loc != 0
        not_in_factor_error(dims[zero_loc])
    end

    lens = lengths(ft)


    inners = vcat(1, cumprod(lens[1:(end-1)]))
    outers = Vector{Int}(length(ft) ./ lens[inds] ./ inners[inds])

    hcat([repeat(Vector(1:length(d)), inner=i, outer=o) for (d, i, o) in
            zip(ft.dimensions[inds], inners[inds], outers)]...)
end

function pattern(ft::Factor)
    lens = lengths(ft)

    inners = vcat(1, cumprod(lens[1:(end-1)]))
    outers = Vector{Int}(length(ft) ./ lens ./ inners)

    hcat([repeat(Vector(1:length(d)), inner=i, outer=o) for (d, i, o) in
            zip(ft.dimensions, inners, outers)]...)
end

"""
Gets the order of states of a dimension
"""
pettern_states(ft::Factor, dim::Symbol) =
    getdim(ft, dim).states[pattern(ft, dims)]

function pattern_states(ft::Factor, dims::Vector{Symbol})
    dims = getdim(ft, dims)
    return hcat([d.states[pattern(ft, d.name)] for d in dims]...)
end

pattern_states(ft::Factor) =
    hcat([d.states[pattern(ft, d.name)] for d in ft.dimensions]...)


# Column access returns the dimensions
Base.getindex(ft::Factor, dim::Symbol) = getdim(ft, dim)
Base.getindex(ft::Factor, dims::Vector{Symbol}) = getdim(ft, dims)
Base.getindex(ft::Factor, ::Colon) = ft.dimensions

Base.getindex(ft::Factor, index::Integer) = ft.dimensions[index]
Base.getindex(ft::Factor, index::Vector{Integer}) = ft.dimensions[index]

"""
Appends a new dimension to a Factor
"""
function Base.push!(ft::Factor, dim::Dimension)
    if name(dim) in names(ft)
        error("Dimension $(name(dim)) already exists")
    end

    v = repeat(ft.v, outer=vcat(repeat([1], outer=ndims(ft.v)), length(dim)))
    ft.dimensions = push!(Vector{Dimension}(ft.dimensions), dim)
    ft.v = v

    return ft
end

function Base.permutedims!(ft::Factor, perm)
    ft.v = permutedims(ft.v, perm)
    ft.dimensions = ft.dimensions[perm]
    return ft
end

Base.permutedims(ft::Factor, perm) = permutedims!(deepcopy(ft), perm)

"""
Get values with dimensions consistent with an assignment
"""
function Base.get(ft::Factor, a::Assignment)
    ind =x = Array{Any}(ndims(ft))
    ind[:] = Colon()
    for (i, d) in enumerate(ft.dimensions)
        if haskey(a, d.name)
            # index in each dimension is location of value
            ind[i] = indexin(d, a[d.name])
            if ind[i] == 0
                # if a[d] is not in assignment
                #  return an empty array
                return ft.v[[]]
            end
        end
    end
    return ft.v[ind...]
end

###############################################################################
#                   IO Stuff

Base.mimewritable(::MIME"text/html", ft::Factor) = true

function Base.show(io::IO, ft::Factor)
    print(io, "$(length(ft)) possible instantiations. $(eltype(ft))")
    for d in ft.dimensions
        println(io, "")
        print(io, "\t")
        print(io, d)
    end
end
Base.show(io::IO, a::MIME"text/html", ft::Factor) = show(io, ft)

