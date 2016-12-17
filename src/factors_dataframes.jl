#
# Factors-DataFrames
#
# Bridge between the two

"""
Convert a Factor to a DataFrame
"""
function DataFrames.DataFrame(ft::Factor)
    df = DataFrames.DataFrame(pattern_states(ft))
    DataFrames.rename!(df, names(df), names(ft))
    df[:v] = ft.v[:]

    return df
end


