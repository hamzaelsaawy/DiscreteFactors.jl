let

c = CardinalDimension(:C, ["as", "ab", "cd", "sd"])
o = OrdinalDimension(:O, ['2', 'J', 'Q', 'K', 'A'])
s = OrdinalStepDimension(:S, 'a', 2, 'z')
l1 = CartesianDimension(:L, 3)
l2 = OrdinalDimension(:L, [3, 4])

@test_throws ArgumentError Factor([c, l1, o, s, l2], Float64)
@test_throws ArgumentError Factor([c, o], rand(4, 6))
@test_throws ArgumentError Factor([c, o], rand(4, 6, 3))
end

let
c = CardinalDimension(:C, ["as", "ab", "cd", "sd"])
o = OrdinalDimension(:O, ['2', 'J', 'Q', 'K', 'A'])
s = OrdinalStepDimension(:S, 'a', 2, 'z')
u = OrdinalUnitDimension(:U, 0, 15)
l = CartesianDimension(:L, 31)

    let
    ft = Factor([c, o, s], Int)
    @test ndims(ft) == 3
    @test size(ft) == (4, 5, 13)
    @test lengths(ft) == [4, 5, 13]
    @test all(ft.v .== 0)
    @test eltype(ft) == (Dimension, Int)
    @test all(names(ft) .== [:C, :O, :S])
    @test length(ft) == prod(lengths(ft))
    @test getdim(ft, :S) == s

    push!(ft, l)

    @test ndims(ft) == 4
    @test size(ft) == (4, 5, 13, 31)
    @test all(lengths(ft) .== [4, 5, 13, 31])
    @test length(ft, :S) == 13
    @test length(ft, :O) == 5
    @test length(ft, :L) == 31
    @test all(length(ft, [:L, :S, :O]) .== [31, 13, 5])
    @test all(ft.v .== 0)
    @test eltype(ft)[2] == Int
    @test all(names(ft) .== [:C, :O, :S, :L])
    @test length(ft) == prod(lengths(ft))
    @test getdim(ft, :L) == l
    @test indexin(ft, :C) == 1
    @test indexin(ft, :L) == 4
    @test ft[:S] == s
    @test ft[4] == l

    ft2 = permutedims(ft, [3, 2, 1, 4])

    @test ndims(ft2) == 4
    @test size(ft2) == (13, 5, 4, 31)
    @test lengths(ft2) == [13, 5, 4, 31]
    @test all(ft2.v .== 0)
    @test eltype(ft2)[2] == Int
    @test all(names(ft2) .== [:S, :O, :C, :L])
    @test length(ft2) == prod(lengths(ft))
    @test (ft[1] == ft2[3])
    @test ft[3] == ft2[1]
    @test ft2[2] == o

    permutedims!(ft, [3, 2, 1, 4])
    @test all(names(ft) .== names(ft2))
    end
end

let
l1 = CartesianDimension(:l1, 2)
l2 = CartesianDimension(:l2, 3)
ft = Factor([l1, l2], [1.0 2 3; 4 5 6])

@test eltype(ft)[2] == Float64
@test ndims(ft) == 2
@test size(ft) == (2, 3)
@test lengths(ft) == [2, 3]
@test all(ft.v .== [1.0 2 3; 4 5 6])
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

let
ft = Factor([:S, :X, :Y], [2, 3, 4], Float64)
@test eltype(ft) == (CartesianDimension{Int}, Float64)
@test ndims(ft) == 3
@test size(ft) == (2, 3, 4)
@test lengths(ft) == [2, 3, 4]
@test all(ft.v .== 0.0)
@test all(names(ft) .== [:S, :X, :Y])
@test length(ft) == 24
end

let
c = CardinalDimension(:C, ["bob", "bill"])
o = CardinalDimension(:O, ['a', 'b', 'c'])

f = Factor([c, o])
expected = ["bob" 'a';
            "bill" 'a';
            "bob" 'b';
            "bill" 'b';
            "bob" 'c';
            "bill" 'c']
@test all(expected .== pattern_states(f))
end

let
ft = Factor(Int)
@test ft.dimensions == Dimension[]
@test ft.v == squeeze([0], 1)
@test lenth(ft) == 1
@test size(ft) == []
@test eltype(ft) == (Factors.Dimension{T},Int64)
end

