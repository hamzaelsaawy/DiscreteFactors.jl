#
# Factors Indexing Tests
#

@testset "Factors Index" begin

@testset "basics" begin
    x = Dimension(:X, [2, 5, 7])
    y = Dimension(:Y, [2, 3])
    z = Dimension(:Z, ['a', 'c'])

    ft = Factor([x, y, z], [1, 2, 3, 2, 3, 4, 4, 6, 7, 8, 10, 16])
    df = DataFrame(ft)

    a = Assignment(:Y=> [3, 2], :K => 16, :Z => 'a')
    @test ft[a].potential == [2 1; 3 2; 4 3]

    ft[Assignment(:X=>2, :Y=> 2, :Z=>'c')] = 1600.0
    @test ft.potential[1, 1, 2] == 1600.0
    @test DataFrame(ft)[sub2ind(ft, 1, 1, 2), :potential] == 1600.0
end

@testset "basics 2" begin
    ft = Factor([1, 2, 3, 2, 3, 4, 4, 6, 7, 8, 10, 16], :X=>3, :Y =>2, :Z=>2)
    df = DataFrame(ft)

    @test_throws MethodError ft[:Y => "waldo"]
    @test_throws ArgumentError ft[:Y => 16]

    a = Assignment(:Y=> 2, :K => 16, :Z => 1)
    @test ft[a].potential == [2, 3, 4]

    ft[:X => 2, :Y => 1, :Z => 2] = 1600.0
    @test ft.potential[2, 1, 2] == 1600.0
    @test DataFrame(ft)[sub2ind(ft, 2, 1, 2), :potential] == 1600.0

    ft[:X => 1, :Y => 2] = 2016
    @test ft.potential[1, 2, :] == [2016, 2016]
end

@testset "dims updating" begin
    ft = Factor([1 4; 2 5; 3 6], :X => 2:4, :Y=>['a', 'b'])
    ft2 = ft[:X=>[3, 2], :Y=>'a']
    @test names(ft2) == [:X]
    @test first(scope(ft2)) == Dimension(:X, [3, 2])
end

@testset "bits" begin
    ft = Factor([1 4; 2 5; 3 6], :X => 2:4, :Y=>['a', 'b'])
    @test_throws BoundsError ft[:X=>[true, false]]

    ft2 = ft[:X=>[true, false, true]]
    @test names(ft2) == [:X, :Y]
    @test getdim(ft2, :X) == Dimension(:X, [2, 4])
    @test ft2.potential == [1 4; 3 6]
end

end
