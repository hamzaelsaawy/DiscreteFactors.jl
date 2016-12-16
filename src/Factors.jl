module Factors

import Base: .==, .!=, .<, .<=, .>, .>=, in, ==
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
       pattern,
       pattern_states,
       getdim,
       reducedim!

include("dimensions.jl")
include("factors_code.jl")
include("factor_reduce.jl")

end # module

