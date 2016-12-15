x = OrdinalDimension(:X, [2, 5, 7])
y = OrdinalDimension(:Y, [2, 3])
z = OrdinalDimension(:Z, ['a', 'c'])

#ft = Factor([x, y, z], map(Char, rand(64:95, 3, 2, 2)))
ft = Factor([x, y, z], Float64)
ft.v[:] = [1, 2, 3, 2, 3, 4, 4, 6, 7, 8, 10, 16]

sum(ft, [:Y, :Z])
sum(ft, [:X, :K, :Z])

