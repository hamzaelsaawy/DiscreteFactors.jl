#
# Factors Reduce Tests
#


let
x = OrdinalDimension(:X, [2, 5, 7])
y = OrdinalDimension(:Y, [2, 3])
z = OrdinalDimension(:Z, ['a', 'c'])

ft = Factor([x, y, z], Float64)
ft.v[:] = [1, 2, 3, 2, 3, 4, 4, 6, 7, 8, 10, 16]

df_original = DataFrame(ft)

@test_throws ArgumentError reducedim!(*, ft, "waldo")
# make sure it didn't change ft
@test DataFrame(ft) == df_original

@test DataFrame(broadcast(+, broadcast(+, ft, :Z, [10, 0.1]), :X, 10)) ==
        DataFrame(broadcast(+, ft, [:X, :Z], [10, [10, 0.1]]))

# squeeze does some weird stuff man ...
@test sum(broadcast(*, ft, :Z, 0), names(ft)).v == squeeze([0.0], 1)

    let
    df = DataFrame(X = [2, 5, 7], v = [123.0, 165.0, 237.0])

    ft2 = broadcast(*, ft, :Z, [1, 10])
    sum!(ft2, [:Y, :Z])

    # ft didn't change
    @test DataFrame(ft2) != df_original
    @test DataFrame(ft2) == df
    end

    let
    df = DataFrame(X = [2, 5, 7], v = [15, 21, 30])
    @test DataFrame(sum(ft, [:Y, :K, :Z, :waldo])) == df
    end
end

error("test join with ft2 only having dimesnions in ft1. and vice versa")

###############################################################################
#                   reduce dims
let
ϕ = Factor([:X, :Y, :Z], [3, 2, 2])
ϕ.potential[:] = Float64[1, 2, 3, 2, 3, 4, 4, 6, 7, 8, 10, 16]

df_original = DataFrame(ϕ)

@test_throws ArgumentError reducedim!(*, ϕ, :waldo)
# make sure it didn't change ϕ
@test DataFrame(ϕ) == df_original

# squeeze does some weird stuff man ...
@test sum(broadcast(*, ϕ, :Z, 0.0), names(ϕ)).potential == squeeze([0.0], 1)

df = DataFrame(X = [1, 2, 3], potential = [123.0, 165.0, 237.0])

ϕ2 = broadcast(*, ϕ, :Z, [1, 10.0])
sum!(ϕ2, [:Y, :Z])

# ϕ didn't change
@test DataFrame(ϕ2) != df_original
@test DataFrame(ϕ2) == df

@test_throws ArgumentError sum(ϕ, [:Y, :K, :Z, :waldo])
end
