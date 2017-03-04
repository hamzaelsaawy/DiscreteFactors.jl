#
# Negatives Tests
#

@testset "negatives" begin
    Factor(:X, [-2016, 4])

    h = set_negative_mode(NegativeError)
    @test_throws ArgumentError log(Factor(:X, [1E-2, 1//4]))
    @test h == NegativeIgnore
    set_negative_mode(h)
end
