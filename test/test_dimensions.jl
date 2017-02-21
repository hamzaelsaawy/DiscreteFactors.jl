let
c = Dimension(:C, ["as", "ab", "cd", "sd"])
o = Dimension(:O, ['2', 'J', 'Q', 'K', 'A'])
s = Dimension(:S, 'a':2:'z')
u = Dimension(:U, 0:15)
l = Dimension(:L, 31)

@test_throws ArgumentError Dimension(:X, ['a', 'a', 'b'])
@test_throws ArgumentError Dimension(:X, [])

@test_throws ArgumentError Dimension(:X, 1:0)
@test_throws ArgumentError Dimension(:X, 3:2:2)

@test_throws ArgumentError Dimension(:X, 0)
@test_throws ArgumentError Dimension(:X, -1)

@test typeof(values(c)) == Vector{String}
@test typeof(values(o)) == Vector{Char}
@test typeof(values(s)) == StepRange{Char, Int64}
@test typeof(values(u)) == UnitRange{Int64}
@test typeof(values(l)) == Base.OneTo{Int64}

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
@test indexin("waldo", c) == 0

@test indexin(['2'], o) == [1]
@test indexin('K', o) == 4
@test indexin(['3'], o) == [0]

@test indexin(['c'], s) == [2]
@test indexin(['b'], s) == [0]
@test indexin('a':'c', s) == [1, 0, 2]

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

#                   equality
let
X1 = Dimension(:X, 3:5)
X2 = Dimension(:X, 3:5)
X3 = Dimension(:X, 3:6)
s = Dimension(:S, 'a':'y')
fakeX = Dimension(:X, (3, 4, 5))

@test X1 == X2
@test X1 != X3
@test X2 != X3
@test X2 != s
# I don't know how I feel about this
@test X1 == fakeX
end

#                   indexin tests
let
    rs = [-10:-1:-15, -15:1:-10, 15:-1:10, 15:-1:10,
        20:-2:10, -10:-2:-20, -21:3:-9]
    ds = map(d -> Dimension(:S, d), rs)

    for d in ds
        @test indexin([-12], values(d)) == indexin([-12], d)
    end
end

let
    rs = ['a':1:'d', 'e':-1:'a', 'a':3:'x']
    ds = map(d -> Dimension(:S, d), rs)

    for d in ds
        @test indexin(['c'], values(d)) == indexin(['c'], d)
        @test indexin(['^'], values(d)) == indexin(['^'], d)
    end
end

let
    d = Dimension(:x, 21:3:40)
    xs = [1, 2, 5, 7, 201, 3, 0, -3, 4, 19, 24]
    @test indexin(xs, d) == indexin(xs, values(d))
end

#                   promotion to OneTo
let
    d = Dimension(:X, 1:3)
    @test typeof(values(d)) == Base.OneTo{Int64}
end

#                   update
let
    x = Dimension(:X, 0:3:15)

    @test_throws ArgumentError update(x, [1, 3])

    i, d = update(x, 0:3:6)
    @test d == Dimension(:X, [0, 3, 6])
    @test i == [1, 2, 3]

    i, d = update(x, [true, true, false, false, true, true])
    @test d == Dimension(:X, [0, 3, 12, 15])
    @test i == [1, 2, 5, 6]

    i, d = update(x, [6])
    @test d == Dimension(:X, [6])
    @test i == [3]

    i, d = update(x, 6)
    @test d == nothing
    @test i == 3
end

#                   iterating
let
    x = Dimension(:X, 0:3:15)
    @test collect(x) == [0, 3, 6, 9, 12, 15]
end

