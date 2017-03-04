#
# Factors Map Tests
#
# log, fill, abs, etc

@testset "Factors Map" begin

@testset "normalize" begin
    ϕ = Factor([:a, :b], Float64[1 2; 3 4])
    ϕ2 = normalize(ϕ, p=1)

    @test elementwise_isapprox(ϕ2.potential, [0.1 0.2; 0.3 0.4])
    @test elementwise_isapprox(ϕ.potential, Float64[1 2; 3 4])

    @test_throws ArgumentError normalize(ϕ, :waldo)

    normalize!(ϕ, p=2)

    @test elementwise_isapprox(ϕ.potential, [1/30 2/30; 1/10 4/30])
end

end
