let
c = CardinalDimension(:C, ["as", "ab", "cd", "sd"])
o = OrdinalDimension(:O, ['2', 'J', 'Q', 'K', 'A'])
s = OrdinalStepDimension(:S, 'a', 2, 'z')
u = OrdinalUnitDimension(:U, 0, 15)
l = CartesianDimension(:L, 31)

@test_throws ErrorException CardinalDimension(:C, ['a', 'a', 'b'])
