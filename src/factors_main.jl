#
# Factors Code
#
# Main file for Factors

"""
    Factor(dims, potential)

Create a Factor corresponding to the potential.
"""
type Factor{D<:Dimension}
    dimensions::Vector{D}
    # the value mapped to each instance
    potential::Array{Float64}

    function Factor(dimensions::Vector{D}, potential::Array)
        (length(dimensions) != ndims(potential)) &&
            throw(ArgumentError("potential must have as many dimensions as dimensions"))

        ([size(potential)...] != [length(d) for d in dimensions]) &&
            throw(ArgumentError("Number of states must match values size"))

        allunique(map(name, dimensions)) || non_unique_dims_error()

        (:potential in map(name, dimensions)) &&
            warn("having a dimension called `potential` will cause problems")

        return new(dimensions, potential)
    end
end

# Factor(lengths::Vector{Int})

Factor{D<:Dimension, V<:Real}(dimensions::Vector{D}, potential::Array{V}) =
    Factor{D}(dimensions, flaot(potential))

Factor{V}(dimension::Dimension, potential::Vector{V}) =
    Factor{typeof(dimension), V}([dimension], v)

function Factor{D<:Dimension}(dimensions::Vector{D}, eltype=Float64)
    potential = zeros(eltype, [length(d) for d in dimensions]...)
    Factor{D, eltype}(dimensions, potential)
end

function Factor(d::Dimension, eltype=Float64)
    potential = zeros(eltype, length(d))
    Factor{typeof(d), eltype}([d], potential)
end

"""
Initialize with a dictionary mapping dimension names (symbols) to lengths,
ranges, or arrays
"""
function Factor{T<:Integer}(d::Dict{Symbol, T}, eltype)
    dimensions = [CartesianDimension(x...) for x in d]
    Factor(dimensions, eltype)
end

"""
Initialize with dimension names, a list of thier lengths, and type of potential

potential will be a zero matrix with type eltype
"""
function Factor{T<:Integer}(dims::Vector{Symbol}, lens::Vector{T}, eltype=Float64)
    if length(dims) != length(dims)
        throw(ArgumentError("Number of dimensions and lengths do not match"))
    end

    dimensions = [CartesianDimension(x...) for x in zip(dims, lens)]
    Factor(dimensions, eltype)
end

"""
Initialize with a vector of dimension names and a value array
"""
function Factor{V}(dims::Vector{Symbol}, potential::Array{V})
    if length(dims) != ndims(potential)
        throw(ArgumentError("Number of dimensions and dimensions " *
                    "of v do not match"))
    end

    dimensions = [CartesianDimension(x...) for x in zip(dims, size(potential))]
    Factor(dimensions, potential)
end

###############################################################################
#                   Methods

"""
Returns tuple of the type of Dimensions and the value mapping, potential
"""
Base.eltype(ft::Factor) = (eltype(ft.dimensions), eltype(ft.potential))
"""
Names of each dimension
"""
Base.names(ft::Factor) = map(name, ft.dimensions)

Base.ndims(ft::Factor) = ndims(ft.potential)

"""
Returns the number of states in each dimension as a tuple
"""
Base.size(ft::Factor) = size(ft.potential)

"""
Same as size, but as a vector instead of a tuple
"""
lengths(ft::Factor) = [size(ft)...]

"""
Total number of elements in the value mapping, potential
"""
Base.length(ft::Factor) = length(ft.potential)
Base.length(ft::Factor, dim::Symbol) = length(getdim(ft, dim))
Base.length(ft::Factor, dims::Vector{Symbol}) =
    [length(ft, dim) for dim in dims]

"""
Returns the index of dimension `dims` in `ft`. Returns 0 if not in `ft`.
"""
function Base.indexin(dims, ft::Factor)
    if isa(dims, Vector{Symbol})
        return indexin(dims, names(ft))
    elseif isa(dims, Vector{Dimension})
        return indexin(dims, ft.dimensions)
    else
        throw(ArgumentError("Unsupported argument type: $typeof(dims)"))
    end
end

function getdim(ft::Factor, dim::Symbol)
    i = indexin([dim], ft)[1]

    if i == 0
        not_in_factor_error(dim)
    end

    return ft.dimensions[i]
end

function getdim(ft::Factor, dims::Vector{Symbol})
    inds = indexin(dims, ft)

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
    ind = indexin([dim], ft)[1]

    if ind == 0
        not_in_factor_error(dim)
    end

    lens = lengths(ft)


    inner = prod(lens[1:(ind-1)])
    outer = Int(length(ft) / inner / lens[ind])

    repeat(Vector(1:length(ft.dimensions[ind])), inner=inner, outer=outer)
end

function pattern(ft::Factor, dims::Vector{Symbol})
    inds = indexin([dims], ft)

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
pattern_states(ft::Factor, dim::Symbol) =
    getdim(ft, dim).states[pattern(ft, dims)]

function pattern_states(ft::Factor, dims::Vector{Symbol})
    dims = getdim(ft, dims)
    return hcat([d.states[pattern(ft, d.name)] for d in dims]...)
end

pattern_states(ft::Factor) =
    hcat([d.states[pattern(ft, d.name)] for d in ft.dimensions]...)

"""
Appends a new dimension to a Factor
"""
function Base.push!(ft::Factor, dim::Dimension)
    if name(dim) in names(ft)
        error("Dimension $(name(dim)) already exists")
    end

    potential = repeat(ft.potential, outer=vcat(repeat([1], outer=ndims(ft.potential)), length(dim)))
    ft.dimensions = push!(Vector{Dimension}(ft.dimensions), dim)
    ft.potential = potential

    return ft
end

function Base.permutedims!(ft::Factor, perm)
    ft.potential = permutedims(ft.potential, perm)
    ft.dimensions = ft.dimensions[perm]
    return ft
end

Base.permutedims(ft::Factor, perm) = permutedims!(deepcopy(ft), perm)

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

