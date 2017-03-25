#
# Factors Map Tests
#
# log, fill, abs, etc

@testset "Factors Map" begin

@testset "normalize" begin
    @testset "1" begin
        ϕ = Factor([:A, :B], [1 2; 3 4])
        ϕ2 = normalize(ϕ, p=1)

        @test_approx_eq ϕ2.potential [0.1 0.2; 0.3 0.4]
        @test ϕ.potential == [1 2; 3 4]

        @test_throws ArgumentError normalize(ϕ, :waldo)

        normalize!(ϕ, p=2)
        @test_approx_eq ϕ.potential [1 2; 3 4]./sqrt(30)
    end

    @testset "2" begin
        ϕ = Factor(-30)
        normalize!(ϕ)
        @test ϕ.potential == reshape([-1.0], ())

        ϕ = Factor(:A, [2, 3])
        normalize!(ϕ, p=1)
        @test_approx_eq ϕ.potential [0.4, 0.6]
    end 

    @testset "3" begin
        ϕ = Factor(1:24, :X=>3, :Y=>2, :Z=>4)
        ϕ2 = normalize(ϕ, :Y)
        @test_approx_eq sum(ϕ2.potential, 2) fill(1.0, (3, 1, 4))

        ϕ3 = normalize(ϕ, [:X, :Z])
        @test_approx_eq sum(ϕ3.potential, [1, 3]) fill(1.0 ,(1, 2, 1))
    end
end

@testset "map" begin
    @testset "1" begin 
        ϕ = Factor(1:16, :X=>4, :Y=>4)
        ϕ2 = map(x -> x+10, ϕ)
        @test ϕ.potential + 10 == ϕ2.potential

        map!(x-> 2*x - 10, ϕ)
        @test ϕ.potential == 2*reshape(1:16, (4,4) ) - 10
    end

    @testset "2" begin 
        ϕ = Factor(:X, 1:4)
        map!(x -> x + 2, ϕ)
        @test ϕ.potential == [3, 4, 5, 6]
    end
    
    @testset "3" begin 
        ϕ = Factor(16)
        ϕ2 = map(log10, ϕ)
        @test ϕ.potential == reshape([16], ())
        @test ϕ2.potential == reshape([log10(16)], ())
    end
end

@testset "rand!" begin
    @testset "1" begin 
        ϕ = Factor(16, :X=>3, :Y=>4)
        rand!(ϕ)
        @test ϕ.potential != 16
    end

    @testset "2" begin 
        ϕ = Factor(3)
        randn!(ϕ)
        @test ϕ.potential != 3
    end
end

@testset "fill!" begin
    @testset "1" begin 
        ϕ = Factor(16, :X=>3, :Y=>4)
        fill!(ϕ, 2016)
        @test all(ϕ.potential .== 2016)
    end

    @testset "2" begin 
        ϕ = Factor(3)
        fill!(ϕ, 19)
        @test ϕ.potential == reshape([19], ())
    end
end

@testset "log, exp, etc." begin
    @testset "1" begin 
        ϕ = Factor(:X=>3, :Y=>4)
        rand!(ϕ)

        @test_approx_eq ϕ.potential exp(log(ϕ)).potential
        @test_approx_eq ϕ.potential log10(exp10(ϕ)).potential
    end

    @testset "2" begin 
        ϕ = Factor(58)
        @test_approx_eq log2(ϕ).potential log2(58)
        @test_approx_eq secd(ϕ).potential secd(58)
    end
end

end
