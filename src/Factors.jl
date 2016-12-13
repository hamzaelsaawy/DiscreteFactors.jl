module Factors

export Dimension,
       CardinalDimension,
       OrdinalStepDimension,
       OrdinalUnitDimension,
       CartesianDimension,

       name,
       eltype,

       Factor

include("dimensions.jl")
include("factors_code.jl")

end # module

