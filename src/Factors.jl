module Factors

import DataFrames

export Dimension,
       CardinalDimension,
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
       getdim

typealias Assignment Dict{Symbol, Any}

include("dimensions.jl")
include("factors_code.jl")

end # module

