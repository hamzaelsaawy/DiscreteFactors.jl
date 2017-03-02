#
# Factors Join
#

"""
    join(op, ϕ1::Factor, ϕ2::Factor, [v0])

Joins two `Factors` with an outer join using `op`

An outer join returns a `Factor` with the union of the two dimensions
The two factors are combined with `Base.broadcast(op, ...)`
"""
function Base.join(op, ϕ1::Factor, ϕ2::Factor, v0=nothing)
    # avoid all the broadcast overhead with a larger array (ideally)
    # more useful for edge cases where one (or both) is (are) singleton
    if length(ϕ1) < length(ϕ2)
        ϕ2, ϕ1 = ϕ1, ϕ2
    end

    common = intersect(ϕ1.dimensions, ϕ2.dimensions)
    index_common1 = indexin(common, ϕ1.dimensions)
    index_common2 = indexin(common, ϕ2.dimensions)

    if [size(ϕ1)[index_common1]...] != [size(ϕ2)[index_common2]...]
        throw(DimensionMismatch("Common dimensions must have same size"))
    end

    # the first dimensions are all from ϕ1
    new_dims = union(ϕ1.dimensions, ϕ2.dimensions)

    if ndims(ϕ2) != 0
        # permute the common dimensions in ϕ2 to the beginning,
        #  in the order that they appear in ϕ1 (and therefore new_dims)
        unique1 = setdiff(ϕ1.dimensions, common)
        unique2 = setdiff(ϕ2.dimensions, common)
        # these will also be the same indices for new_dims
        index_unique1 = indexin(unique1, ϕ1.dimensions)
        index_unique2 = indexin(unique2, ϕ2.dimensions)
        perm = vcat(index_common2, index_unique2)
        temp = permutedims(ϕ2.potential, perm)

        # reshape by lining up the common dims in ϕ2 with those in ϕ1
        size_unique2 = size(ϕ2)[index_unique2]
        # set those dims to have dimension 1 for data in ϕ2
        reshape_lengths = vcat(size(ϕ1)..., size_unique2...)
        #new_pot = duplicate(ϕ1.potential, size_unique2)
        new_pot = Array{Float64}(reshape_lengths...)
        reshape_lengths[index_unique1] = 1
        temp = reshape(temp, (reshape_lengths...))
    else
        new_pot = similar(ϕ1.potential)
        temp = ϕ2.potential
    end

    # ndims(ϕ1) == 0 implies ndims(ϕ2) == 0
    if ndims(ϕ1) == 0
        new_pot = squeeze([op(ϕ1.potential[1], temp[1])], 1)
    else
        broadcast!(op, new_pot, ϕ1.potential, temp)
    end

    return Factor(new_dims, new_pot)
end

*(ϕ1::Factor, ϕ2::Factor) = join(*, ϕ1, ϕ2)
/(ϕ1::Factor, ϕ2::Factor) = join(/, ϕ1, ϕ2)
+(ϕ1::Factor, ϕ2::Factor) = join(+, ϕ1, ϕ2)
-(ϕ1::Factor, ϕ2::Factor) = join(-, ϕ1, ϕ2)

# code for an inner join, if its ever done
# error("not supported")
# new_dims = getdim(ft1, common)
#
# if isempty(common)
#     # weird magic for a zero-dimensional array
#     v_new = squeeze(zero(eltype(ft1), 0), 1)
# else
#     if reducehow == nothing
#         throw(ArgumentError("Need reducehow"))
#     end
#
#     inds1 = (findin(ft1.dimensions, common)...)
#     inds2 = (findin(ft2.dimensions, common)...)
#
#     if v0 != nothing
#         v1_new = squeeze(reducedim(op, ft1.v, inds1, v0), inds)
#         v2_new = squeeze(reducedim(op, ft2.v, inds2, v0), inds)
#     else
#         v1_new = squeeze(reducedim(op, ft1.v, inds1), inds)
#         v2_new = squeeze(reducedim(op, ft2.v, inds2), inds)
# new_m = zeros(eltype(ft1.v), reshape_lengths)
#     end
#     v_new = op(v1_new, v2_new)
# end
