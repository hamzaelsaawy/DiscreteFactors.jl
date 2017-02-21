let
c = CardinalDimension(:C, ["as", "ab", "cd", "sd"])
o = OrdinalDimension(:O, ['2', 'J', 'Q', 'K', 'A'])
s = OrdinalStepDimension(:S, 'a', 2, 'z')
u = OrdinalUnitDimension(:U, 0, 15)
l = CartesianDimension(:L, 31)

@test_throws ArgumentError CardinalDimension(:C, ['a', 'a', 'b'])
@test_throws ArgumentError CardinalDimension(:C, ['a'])
@test_throws ArgumentError CardinalDimension(:C, [])

@test_throws ArgumentError OrdinalDimension(:O, ['a', 'a', 'b'])
@test_throws ArgumentError OrdinalDimension(:O, ['a'])
@test_throws ArgumentError OrdinalDimension(:O, [])

@test_throws MethodError OrdinalStepDimension(:S, 1, 'a', 3)
@test_throws MethodError OrdinalStepDimension(:S, 'a', 'b', 'c')
@test_throws ArgumentError OrdinalStepDimension(:S, 1, 1, 1)

@test_throws ArgumentError OrdinalUnitDimension(:U, 1, 1)
@test_throws ArgumentError OrdinalUnitDimension(:U, 1, -1)
@test_throws MethodError OrdinalUnitDimension(:U, 1, 'a')

@test_throws ArgumentError CartesianDimension(:C, 1)
@test_throws ArgumentError CartesianDimension(:C, -2)
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

@test indexin(["ab"], c) == [2]
@test indexin(["waldo"], c) == [0]
@test_throws MethodError indexin([16], c)

@test indexin(['2'], o) == [1]
@test indexin('K', o) == 4
@test indexin(['3'], o) == [0]
@test indexin(:, o) == [1, 2, 3, 4, 5]

@test indexin(['c'], s) == [2]
@test indexin(['b'], s) == [0]
@test indexin('a':'c', s) == [1, 0, 2]
@test_throws MethodError indexin([16], s)

@test indexin([0, 15, 16], u) == [1, 16, 0]

@test indexin(0, l) == 0
@test indexin([16], l)== [16]
@test indexin([1, 31, 58], l) == [1, 31, 0]

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

#                   type promotion/inference
let
# TODO test dimension

l = dimension(:l, (1, 2, 'a'))
@test eltype(l) == Char

l = dimension(:l, (1, 2, 3.5))
@test eltype(l) == Float64

end

#                   indexin tests
let
    rs = [-10:-1:-15, -15:1:-10, 15:-1:10, 15:-1:10,
        20:-2:10, -10:2:-20, -21:3:-9]
    ds = map(d -> dimension(:S, d), rs)

    for d in ds
        @test indexin([-12], values(d)) == indexin([-12], d)
    end
end

let
    rs = ['a':1:'d', 'e':-1:'a', 'a':3:'x']
    ds = map(d -> dimension(:S, d), rs)

    for d in ds
        @test indexin(['c'], values(d)) == indexin(['c'], d)
        @test indexin(['^'], values(d)) == indexin(['^'], d)
    end
end

let
    d = dimension(:x, 21:3:0)
    xs = [1, 2, 5, 7, 201, 3, 0, -3, 4, 19, 24]
    @test indexin(xs, d) == indexin(xs, value(d))
end

#                   update
let
    x = Dimension(:X, 0:3:15)

    @test false
    update(x, [1, 3])
    update(x, 0:3:6)
    update(x, [true, true, false, false, true, true])
    update(x, 6) # returns just a number and `nothing`
end

let
X1 = OrdinalUnitDimension(:X, 3, 5)
X2 = OrdinalUnitDimension(:X, 3, 5)
X3 = OrdinalUnitDimension(:X, 3, 6)
s = OrdinalStepDimension(:S, 'a', 'y')
fakeX = OrdinalDimension(:X, [3, 4, 5])
fakeX2 = CardinalDimension(:X, [3, 4, 5])

@test X1 == X2
@test X1 != X3
@test X2 != X3
@test X2 != s
# I don't know how I feel about this
@test X1 == fakeX
@test X1 != fakeX2
end

let
# default step value of 1
s2 = OrdinalStepDimension(:S2, 'a', 'y')

@test indexin('x', s2) == 24
@test step(s2.states) == 1
@test first(s2) == 'a'
@test last(s2) == 'y'
@test eltype(s2) == Char
end

