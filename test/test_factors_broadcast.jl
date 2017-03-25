#
# Factors Broadcast Tests
#

@testset "Factors Broadcast" begin

@testset "basic" begin
        ϕ = Factor([:X, :Y], [1 2; 3 4; 5 6])

        @test_approx_eq(
                broadcast(*, ϕ, [:Y, :X], [[10, 0.1], 100.0]).potential,
                Float64[1000 20; 3000 40; 5000 60])

        @test_throws ArgumentError broadcast(*, ϕ, [:X, :Z], [[10, 1, 0.1], [1, 2, 3]])
        @test_throws ArgumentError broadcast(*, ϕ, [:Z, :X, :A], [2, [10, 1, 0.1], [1, 2, 3]])
        @test_throws DimensionMismatch broadcast(*, ϕ, :X, [2016, 58.0])
        @test_throws MethodError broadcast(*, ϕ, :X, "Asdas")
end

@testset "2" begin
        ϕ = Factor(:X=>3, :Y=>2, :Z=>2)
        rand!(ϕ)

        @test_approx_eq(
                broadcast(+, broadcast(+, ϕ, :Z, [10, 0.1]), :X, [1, 10, 1]).potential,
                broadcast(+, ϕ, [:X, :Z], [[1, 10, 1], [10, 0.1]]).potential)
end

end
