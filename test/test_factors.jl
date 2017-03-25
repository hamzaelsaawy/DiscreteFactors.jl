#
# Factors Tests
#
# constructors, basic functions

@testset "Factors Main" begin

@testset "bad constructors" begin
    c = Dimension(:C, ["as", "ab", "cd", "sd"])
    o = Dimension(:O, ['2', 'J', 'Q', 'K', 'A'])
    s = Dimension(:S, 'a':2:'z')
    l1 = Dimension(:L, 3)
    l2 = Dimension(:L, [3, 4])

    @test_throws ArgumentError Factor([c, l1, o, s, l2])
    @test_throws DimensionMismatch Factor([c, o], rand(4, 6))
    @test_throws DimensionMismatch Factor([c, o], rand(4, 6, 3))
    @test_throws DimensionMismatch Factor(rand(4, 6, 3), :X=>3, :Y=>3, :Z=>4)
    @test_throws DimensionMismatch Factor(rand(4, 6, 3), :X=>3, :Y=>3)

    @test_throws ArgumentError Factor(Dimension(:X, []), Float64[])
end

@testset "basics" begin
    c = Dimension(:C, ["as", "ab", "cd", "sd"])
    o = Dimension(:O, ['2', 'J', 'Q', 'K', 'A'])
    s = Dimension(:S, 'a':2:'z')
    u = Dimension(:U, 0:15)
    l = Dimension(:L, 31)

    ft = Factor([c, o, s])
    @test ndims(ft) == 3
    @test indexin([:C], ft) == [1]
    @test indexin(:O, ft) == 2
    @test indexin(o, ft) == 2
    @test getdim(ft, :S) == s
    @test size(ft) == (4, 5, 13)
    @test all(values(ft) .== 0)
    @test eltype(ft) == (Float64)
    @test all(names(ft) .== [:C, :O, :S])
    @test length(ft) == prod(size(ft))
    @test getdim(ft, :S) == s

    ft = push(ft, l)

    @test ndims(ft) == 4
    @test size(ft) == (4, 5, 13, 31)
    @test size(ft, :S) == 13
    @test size(ft, :O) == 5
    @test size(ft, :L) == 31
    @test size(ft, :L, :S, :O) == (31, 13, 5)
    @test all(ft.potential .== 0)
    @test names(ft) == [:C, :O, :S, :L]
    @test length(ft) == prod(size(ft))
    @test getdim(ft, :L) == l
    @test indexin(:C, ft) == 1
    @test indexin([:L], ft) == [4]
    @test ft.dimensions[4] == l

    ft2 = permutedims(ft, [3, 2, 1, 4])

    @test ndims(ft2) == 4
    @test size(ft2) == (13, 5, 4, 31)
    @test all(ft2.potential .== 0)
    @test all(names(ft2) .== [:S, :O, :C, :L])
    @test length(ft2) == prod(size(ft))
    @test indexin(:S, ft2) == 1
    @test indexin(:C, ft2) == 3
    @test getdim(ft2, :S) == getdim(ft, :S)
    @test getdim(ft2, :L) == getdim(ft, :L)
    @test ft.dimensions[1] == ft2.dimensions[3]
    @test ft.dimensions[3] == ft2.dimensions[1]
    @test ft2.dimensions[2] == o

    permutedims!(ft, [3, 2, 1, 4])
    @test names(ft) == names(ft2)
end

@testset "basics 2" begin
    l1 = Dimension(:l1, 2)
    l2 = Dimension(:l2, 3)
    ft = Factor([l1, l2], 1:6)

    @test eltype(ft) == Float64
    @test ndims(ft) == 2
    @test size(ft) == (2, 3)
    @test all(ft.potential .== [1.0 3 5; 2 4 6])
    @test all(names(ft) .== [:l1, :l2])
    @test length(ft) == 6

    @test sub2ind(ft, 2, 3) == 6
    @test sub2ind(ft, 2, 1) == 2
    @test sub2ind(ft, 2, 2) == 4

    @test ind2sub(ft, 5) == (1, 3)
    @test ind2sub(ft, 3) == (1, 2)

    @test all(pattern(ft, :l1) .== [1, 2, 1, 2, 1, 2])
    @test all(pattern(ft, :l2) .== [1, 1, 2, 2, 3, 3])
end

@testset "empty" begin
    # see if any puke up errors
    Factor(2016)
    Factor(Inf)
    Factor(NaN)
    f = Factor(31)
    @test ndims(f) == 0
    @test names(f) == Symbol[]
    @test scope(f) == Dimension[]
    @test length(f) == 1
    @test size(f) == ()
end

@testset "pairs" begin
    @testset "default" begin
        ft = Factor(:S => 2, :X=>3, :Z=>4)
        @test ndims(ft) == 3
        @test size(ft) == (2, 3, 4)
        @test all(values(ft) .== 0)
        @test all(names(ft) .== [:S, :X, :Z])
        @test length(ft) == 24
    end

    @testset "empty" begin
        ft = Factor(nothing, :S => 2, :X=>3, :Z=>4)
        @test ndims(ft) == 3
        @test size(ft) == (2, 3, 4)
        @test all(names(ft) .== [:S, :X, :Z])
        @test length(ft) == 24
    end

    @testset "init" begin
        ft = Factor(2016, :S => 2, :X=>3, :Z=>4)
        @test size(ft) == (2, 3, 4)
        @test all(ft.potential .== 2016)
    end

    @testset "reshape" begin
        ft = Factor(1:24, :S => 2, :X=>3, :Z=>4)
        @test size(ft) == (2, 3, 4)
        @test all(ft.potential[:] .== collect(1:24))
    end

    @test_throws DimensionMismatch Factor(1:13, :X=>3, :Y=>4)
end

@testset "dict" begin
    @testset "default" begin
        ft = Factor(Assignment(:S => 2, :X=>3, :Z=>4))
        @test ndims(ft) == 3
        @test size(ft, :S, :X, :Z) == (2, 3, 4)
        @test all(values(ft) .== 0)
        @test length(ft) == 24
    end

    @testset "empty" begin
        ft = Factor(Assignment(:X => 3, :S=>2, :Z=>4), nothing)
        @test size(ft, :S, :X, :Z) == (2, 3, 4)
    end

    @testset "init" begin
        ft = Factor(Assignment(:X => 3, :S=>2, :Z=>4), 2016)
        @test all(ft.potential .== 2016)
    end
end

@testset "1 dimensional" begin
    @testset "default" begin
        ft = Factor(:S, 11:14)
        @test ndims(ft) == 1
        @test size(ft) == (4,)
        @test all(values(ft) .== [11, 12, 13, 14])
        @test length(ft) == 4
    end

    @testset "pairs" begin
        ft = Factor(11:14, :S => 4)
        @test ndims(ft) == 1
        @test size(ft) == (4,)
        @test all(values(ft) .== [11, 12, 13, 14])
        @test length(ft) == 4
    end

    @testset "default" begin
        ft = Factor(33, :S=>2:6)
        @test ndims(ft) == 1
        @test size(ft) == (5,)
        @test all(values(ft) .== 33)
    end
end

@testset "pattern states" begin
    c = Dimension(:C, ["bob", "bill"])
    o = Dimension(:O, ['a', 'b', 'c'])

    f = Factor([c, o])
    expected = ["bob" 'a';
                "bill" 'a';
                "bob" 'b';
                "bill" 'b';
                "bob" 'c';
                "bill" 'c']
    @test all(expected .== pattern_states(f))
end

end
