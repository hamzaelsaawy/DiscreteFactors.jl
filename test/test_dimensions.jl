let
c = CardinalDimension(:C, ["as", "ab", "cd", "sd"])
o = OrdinalDimension(:O, ['2', 'J', 'Q', 'K', 'A'])
s = OrdinalStepDimension(:S, 'a', 2, 'z')
u = OrdinalUnitDimension(:U, 0, 15)
l = CartesianDimension(:L, 31)

@test_throws ErrorException CardinalDimension(:C, ['a', 'a', 'b'])
@test_throws ErrorException CardinalDimension(:C, ['a'])
@test_throws ErrorException CardinalDimension(:C, [])

@test_throws ErrorException OrdinalDimension(:O, ['a', 'a', 'b'])
@test_throws ErrorException OrdinalDimension(:O, ['a'])
@test_throws ErrorException OrdinalDimension(:O, [])

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
@test name(o) == :O
@test name(s) == :S
@test name(u) == :U
@test name(l) == :L

@test length(c) == 4
@test length(o) == 5
@test length(s) == 13
@test length(u) == 16
@test length(l) == 31

@test findin(c, "ab") == 2
@test findin(c, "waldo") == 0
@test_throws MethodError findin(c, 16) == 0

@test findin(o, '2') == 1
@test findin(o, 'K') == 4
@test findin(o, '3') == 0

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
@test first(o) == '2'
@test first(s) == 'a'
@test first(u) == 0
@test first(l) == 1

@test last(c) == "sd"
@test last(o) == 'A'
@test last(s) == 'y'
@test last(u) == 15
@test last(l) == 31

@test "ab" in c
@test !("asc" in c)

@test 'J' in o
@test !('3' in o)

@test 'c' in s
@test !('b' in s)

@test 13 in u
@test !(16 in u)

@test 16 in l
@test !(0 in l)

@test all((c .== "cd") .== BitArray([false, false, true, false]))
@test all((c .== "waldo") .== falses(4))

@test all((o .== 'Q') .== BitArray([false, false, true, false, false]))
@test all((o .== '3') .== falses(5))

@test all((s .== 'b') .== falses(13))

@test all((u .== 16) .== falses(16))

@test all((l .== 33) .== falses(31))

# cardinal doesn't have less than, greater than
@test_throws MethodError c < "cd"

@test all((o .<= 'Q') .== BitArray([true, true, true, false, false]))
@test all((o .>= 'J') .== BitArray([false, true, true, true, true]))
@test all((o .> 'A') .== falses(5))
@test all((o .> 'N') .== falses(5))
@test all((o .> '0') .== falses(5))

@test eltype(c) == String
@test eltype(o) == Char
@test eltype(s) == Char
@test eltype(u) == Int
@test eltype(l) == Int
@test all(values(c) .== ["as", "ab", "cd", "sd"])
@test all(values(o) .== ['2', 'J', 'Q', 'K', 'A'])
@test all(values(s) .== 'a':2:'z')
@test all(values(u) .== 0:15)
@test all(values(l) .== 1:31)
end

let
X1 = OrdinalUnitDimension(:X, 3, 5)
X2 = OrdinalUnitDimension(:X, 3, 5)
X3 = OrdinalUnitDimension(:X, 3, 6)
s = OrdinalStepDimension(:S, 'a', 'y')

@test X1 == X2
@test X1 != X3
@test X2 != X3
@test X2 != s
end
let
# default step value of 1
s2 = OrdinalStepDimension(:S2, 'a', 'y')

@test findin(s2, 'x') == 24
@test step(s2.states) == 1
@test first(s2) == 'a'
@test last(s2) == 'y'
@test eltype(s2) == Char
end

