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

        ft = Factor(:A, [2, 3])
        normalize!(ft, p=1)
        @test_approx_eq ft.potential [0.4, 0.6]
    end 

    @testset "3" begin
        ft = Factor(1:24, :X=>3, :Y=>2, :Z=>4)
        ft2 = normalize(ft, :Y)
        @test_approx_eq sum(ft2.potential, 2) fill(1.0, (3, 1, 4))

        ft3 = normalize(ft, [:X, :Z])
        @test_approx_eq sum(ft3.potential, [1, 3]) fill(1.0 ,(1, 2, 1))
    end
end

@testset "map" begin
    @testset "1" begin 
        ft = Factor(1:16, :X=>4, :Y=>4)
        ft2 = map(x -> x+10, ft)
        @test ft.potential + 10 == ft2.potential

        map!(x-> 2*x - 10, ft)
        @test ft.potential == 2*reshape(1:16, (4,4) ) - 10
    end

    @testset "2" begin 
        ft = Factor(:X, 1:4)
        map!(x -> x + 2, ft)
        @test ft.potential == [3, 4, 5, 6]
    end
    
    @testset "3" begin 
        ft = Factor(16)
        ft2 = map(log10, ft)
        @test ft.potential == reshape([16], ())
        @test ft2.potential == reshape([log10(16)], ())
    end
end

@testset "rand!" begin
    @testset "1" begin 
        ft = Factor(16, :X=>3, :Y=>4)
        rand!(ft)
        @test ft.potential != 16
    end

    @testset "2" begin 
        ft = Factor(3)
        randn!(ft)
        @test ft.potential != 3
    end
end

@testset "fill!" begin
    @testset "1" begin 
        ft = Factor(16, :X=>3, :Y=>4)
        fill!(ft, 2016)
        @test all(ft.potential .== 2016)
    end

    @testset "2" begin 
        ft = Factor(3)
        fill!(ft, 19)
        @test ft.potential == reshape([19], ())
    end
end

@testset "log, exp, etc." begin
    @testset "1" begin 
        ft = Factor(:X=>3, :Y=>4)
        rand!(ft)

        @test_approx_eq ft.potential exp(log(ft)).potential
        @test_approx_eq ft.potential log10(exp10(ft)).potential
    end

    @testset "2" begin 
        ft = Factor(58)
        @test_approx_eq log2(ft).potential log2(58)
        @test_approx_eq secd(ft).potential secd(58)
    end
end
end
