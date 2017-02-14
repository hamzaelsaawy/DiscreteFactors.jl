#
# Factor-DataFrame conversion
#

function Base.convert(::Type{DataFrames.DataFrame}, ϕ::Factor)
    df = DataFrames.DataFrame(pattern_states(ϕ))
    DataFrames.rename!(df, names(df), names(ϕ))
    df[:potential] = ϕ.potential[:]

    return df
end

