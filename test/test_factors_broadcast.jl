#
# Factors Broadcast Tests
#

###############################################################################
#                   broadcast
let
ϕ = Factor([:X, :Y], Float64[1 2; 3 4; 5 6])

@test elementwise_isapprox(
        broadcast(*, ϕ, [:Y, :X], [[10, 0.1], 100.0]).potential,
        Float64[1000 20; 3000 40; 5000 60])

@test_throws ArgumentError broadcast(*, ϕ, [:X, :Z], [[10, 1, 0.1], [1, 2, 3]])

@test_throws ArgumentError broadcast(*, ϕ, [:Z, :X, :A], [2, [10, 1, 0.1], [1, 2, 3]])

@test_throws DimensionMismatch broadcast(*, ϕ, :X, [2016, 58.0])
end

let
ϕ = Factor([:X, :Y, :Z], [3, 2, 2])
ϕ.potential[:] = Float64[1, 2, 3, 2, 3, 4, 4, 6, 7, 8, 10, 16]

@test DataFrame(broadcast(+, broadcast(+, ϕ, :Z, [10, 0.1]), :X, 10.0)) ==
        DataFrame(broadcast(+, ϕ, [:X, :Z], [10.0, [10, 0.1]]))
end
