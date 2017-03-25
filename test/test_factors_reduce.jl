#
# Factors Reduce Tests
#

@testset "Factors Redude" begin

@testset "main" begin
    x = Dimension(:X, [2, 5, 7])
    y = Dimension(:Y, [2, 3])
    z = Dimension(:Z, ['a', 'c'])

    ϕ = Factor([x, y, z], [1, 2, 3, 2, 3, 4, 4, 6, 7, 8, 10, 16])

    df_original = DataFrame(ϕ)

    @test_throws ArgumentError reducedim(*, ϕ, :waldo)
    # make sure it didn't change ϕ
    @test DataFrame(ϕ) == df_original

    @test sum(broadcast(*, ϕ, :Z, 0)).potential == reshape([0.0], ())

    df = DataFrame(X = [2, 5, 7], potential = [123.0, 165.0, 237.0])

    ϕ2 = broadcast(*, ϕ, :Z, [1, 10])
    ϕ2 = sum(ϕ2, [:Y, :Z])

    # ϕ didn't change
    @test DataFrame(ϕ2) != df_original
    @test DataFrame(ϕ2) == df

    df2 = DataFrame(X = [2, 5, 7], potential = [15, 21, 30])
    @test DataFrame(sum(ϕ, [:Y, :Z])) == df2

    @test first(Z(ϕ).potential) == sum(ϕ.potential)
end

@testset "singleton" begin
    ϕ = Factor(1:16, :X=>4, :Z=>4)
    z = Z(ϕ)
    @test ndims(z) == 0
    @test z.potential == reshape([136], ())
    @test names(z) == Symbol[]

    ϕ2 = sum(ϕ, :Z)
    @test ϕ2.potential == [28, 32, 36, 40]
    @test_approx_eq prod(ϕ2).potential 1290240.0

    ϕs = Factor(23)
    @test minimum(ϕs).potential == reshape([23], ())
end

end
