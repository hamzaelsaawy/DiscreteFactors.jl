module Factors

import Base.==
import DataFrames

export Dimension,
       CardinalDimension,
       OrdinalDimension,
       OrdinalStepDimension,
       OrdinalUnitDimension,
       CartesianDimension,

       name,
       eltype,

       Assignment,

       Factor,
       lengths,
       indexof,
       pattern,
       pattern_states,
       getdim

include("dimensions.jl")
include("factors_code.jl")

end # module

