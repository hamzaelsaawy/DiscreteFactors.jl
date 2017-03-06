#
# Factors Iterating Tests
#

@testset "Factors Iter" begin

@testset "pattern" begin
    ft = Factor(:l1=>2, :l2=>3)
    @test pattern(ft, :l1) == [1 2 1 2 1 2]'
    @test pattern(ft, [:l1, :l2]) == pattern(ft)
    @test pattern(ft) == [1 1; 2 1; 1 2; 2 2; 1 3; 2 3]
end

@testset "pattern states" begin
    A = Dimension(:A, 2:4)
    B = Dimension(:B, 'a':'e')
    C = Dimension(:C, ["aa", "gg", "ss"])

    ft = Factor([A, B, C])
    len = length(ft)
    manual = Array{Any}(len, 3)
    for (i, a) in enumerate(A)
        for (j, b) in enumerate(B)
            for (k, c) in enumerate(C)
                l = sub2ind(ft, i, j ,k)
                manual[l, :] = [a, b, c]
            end
        end
    end
    @test pattern_states(ft) == manual
end

@testset "pattern iter" begin
    A = Dimension(:A, 2:4)
    B = Dimension(:B, 'a':'e')
    C = Dimension(:C, ["aa", "gg", "ss"])

    ft = Factor([A, B, C])
    len = length(ft)

    for (i, at) in enumerate(ft)
        sub = ind2sub(ft, i)
        @test at == sub2at(ft, sub...)
    end
end

end
