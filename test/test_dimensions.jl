let
c = CardinalDimension(:C, ["as", "ab", "cd", "sd"])
s = OrdinalStepDimension(:S, 'a', 2, 'z')
u = OrdinalUnitDimension(:U, 0, 15)
l = CartesianDimension(:L, 31)

@test_throws ErrorException CardinalDimension(:C, ['a', 'a', 'b'])
@test_throws ErrorException CardinalDimension(:C, ['a'])
@test_throws ErrorException CardinalDimension(:C, [])

@test_throws MethodError OrdinalStepDimension(:S, 1, 'a', 3)
@test_throws MethodError OrdinalStepDimension(:S, 'a', 'b', 'c')
@test_throws ErrorException OrdinalStepDimension(:S, 1, 1, 1)

@test_throws ErrorException OrdinalUnitDimension(:U, 1, 1)
@test_throws ErrorException OrdinalUnitDimension(:U, 1, -1)
@test_throws MethodError OrdinalUnitDimension(:U, 1, 'a')

@test_throws ErrorException CartesianDimension(:C, 1)
@test_throws ErrorException CartesianDimension(:C, -2)
@test_throws MethodError CartesianDimension(:C, "as")

@test name(c) == :C
@test name(s) == :S
@test name(u) == :U
@test name(l) == :L

@test length(c) == 4
@test length(s) == 13
@test length(u) == 16
@test length(l) == 31

@test findin(c, "ab") == 2
@test findin(c, "waldo") == 0
@test_throws MethodError findin(c, 16) == 0

@test findin(s, 'c') == 2
@test findin(s, 'b') == 0
@test findin(s, 16) == 0

@test findin(u, 0) == 1
@test findin(u, 15)== 16
@test findin(u, 16) == 0

@test findin(l, 0) == 0
@test findin(l, 16)== 16
@test findin(l, 1) == 1
@test findin(l, 31) == 31
@test findin(l, 32) == 0

@test first(c) == "as"
@test first(s) == 'a'
@test first(u) == 0
@test first(l) == 1

@test last(c) == "sd"
@test last(s) == 'y'
@test last(u) == 15
@test last(l) == 31

@test eltype(c) == String
@test eltype(s) == Char
@test eltype(u) == Int
@test eltype(l) == Int

@test all(values(c) .== ["as", "ab", "cd", "sd"])
@test all(values(s) .== 'a':2:'z')
@test all(values(u) .== 0:15)
@test all(values(l) .== 1:31)
end

let 
s2 = OrdinalStepDimension(:S2, 'a', 'y')

@test findin(s2, 'x') == 24
@test step(s2.states) == 1
@test first(s2) == 'a'
@test last(s2) == 'y'
@test eltype(s2) == Char
end

