#
# Factors Indexing Tests
#

@testset "Factors Index" begin

@testset "" begin
    x = OrdinalDimension(:X, [2, 5, 7])
    y = OrdinalDimension(:Y, [2, 3])
    z = OrdinalDimension(:Z, ['a', 'c'])

    ft = Factor([x, y, z], Float64)
    ft.v[:] = [1, 2, 3, 2, 3, 4, 4, 6, 7, 8, 10, 16]

    df = DataFrame(ft)

    a = Assignment(:Y=> [3, 2], :K => 16, :Z => 'a')
    @test ft[a] == [4.0 8; 6 10]

    ft[Assignment(:X=>2, :Y=> 2, :Z=>'c')] = 1600.0
    @test ft.v[1, 1, 2] == 1600.0
    @test DataFrame(ft)[7, :v] == 1600.0
end

@testset "" begin
    ϕ = Factor([:X, :Y, :Z], [3, 2, 2])
    ϕ.potential[:] = [1, 2, 3, 2, 3, 4, 4, 6, 7, 8, 10, 16]

    df = DataFrame(ϕ)

    @test_throws TypeError ϕ[Assignment(:Y => "waldo")]
    @test_throws BoundsError ϕ[Assignment(:Y => 16)]

    a = Assignment(:Y=> 2, :K => 16, :Z => 1)
    ϕ[a].potential  == Float64[2, 3, 4]

    ϕ[Assignment(:X => 2, :Y => 1, :Z => 2)] = 1600.0
    @test ϕ.potential[2, 1, 2] == 1600.0
    @test DataFrame(ϕ)[sub2ind(ϕ, 2, 1, 2), :potential] == 1600.0

    ϕ[Assignment(:X => 1, :Y => 2)] = 2016
    @test ϕ.potential[1, 2, :] == Float64[2016, 2016]
end

end
