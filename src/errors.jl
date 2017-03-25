#
# Errors
#
# (many of) the errors thrown

####################################################################################################
#                                   Dimensions
empty_support_error(name::Symbol) = throw(ArgumentError(repr(name) * "'s support is empty"))

non_unique_support_error() = throw(ArgumentError("support must have unique values"))

not_in_dimension_error(v, d::Dimension) =
        throw(ArgumentError("value " * repr(v) * " is not in dimension " * repr(d)))

####################################################################################################
#                                   Factors

non_unique_dims_error() = throw(ArgumentError("Dimension names must be unique"))

not_enough_dims_error() =
        throw(DimensionMismatch("`potential`s number of " *
                "dimensions must match the length of `dimensions`"))

invalid_dim_sizes() = throw(DimensionMismatch("dimension lengths must match shape of `potential`"))

not_in_factor_error(name::Symbol, φ::Factor) =
        throw(ArgumentError(repr(name) * " is not in factor " * repr(φ)))

invalid_dims_error(func, got) =
        throw(TypeError(func, "type of dimensions", Union{Symbol, AbstractVector{Symbol}}, got))

assignment_missing_error(name::Symbol) =
        throw(ArgumentError("Assignment is missing variable " * repr(name)))

nonsingleton_assignment_error(name::Symbol) =
        throw(ArgumentError("Assignment to " * repr(name) * " should be a single value"))
