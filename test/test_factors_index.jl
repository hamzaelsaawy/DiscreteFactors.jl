let

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

