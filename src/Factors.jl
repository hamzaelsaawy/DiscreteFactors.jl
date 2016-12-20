# __precompile__(true)

module Factors

import Base: .==, .!=, .<, .<=, .>, .>=, in, ==, *
# for conversion to DataFrames ...
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
       reducedim!,
       duplicate

include("errors.jl")
include("dimensions.jl")
include("factors_code.jl")
include("factors_access.jl")
include("factors_dims.jl")
include("factors_dataframes.jl")

end # module

# TODO add FactorView or subarray version to access subarray, then squeeze ...
# TODO add norm() and normalize() functions
# TODO apply function across dimension??
# TODO broadcast_reduce
# TODO indexin for dims with Float ranges (implemented differently?)
# TODO sub2ind for Assignments
# TODO FloatRange dimension and indexin?
