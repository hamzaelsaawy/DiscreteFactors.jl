#
# Factors Iterating Tests
#

@testset "Factors Iter" begin

@testset "pattern" begin
    ϕ = Factor(:l1=>2, :l2=>3)
    @test pattern(ϕ, :l1) == [1 2 1 2 1 2]'
    @test pattern(ϕ, [:l1, :l2]) == pattern(ϕ)
    @test pattern(ϕ) == [1 1; 2 1; 1 2; 2 2; 1 3; 2 3]
end

end
