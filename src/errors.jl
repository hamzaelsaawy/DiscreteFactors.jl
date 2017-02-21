#
# Errors
#
# All the errors that can be thrown

empty_support_error() = throw(ArgumentError("dimension support is empty"))

not_enough_dims_error() = throw(ArgumentError("`potential` must have as " *
            "many dimensions as `dimensions`"))

non_unique_support_error() =
    throw(ArgumentError("support must have unique values"))

invalid_dim_sizes() = throw(ArgumentError("dimension lengths must match " *
            "shape of `potential`"))

non_unique_dims_error() = throw(ArgumentError("dimensions must be unique"))

not_in_factor_error(name) = throw(ArgumentError(repr(name) * " is not " *
            "a valid dimension"))

not_in_dimension_error(v, d::Dimension) =
    throw(ArgumentError(repr(v) * " is not in dimension " * repr(d)))

not_in_factor_error(name::Symbol, φ::Factor) =
        throw(ArgumentError(repr(name) * " is not in factor " * repr(φ)))

invalid_dims_error(func, got) = throw(TypeError(func, "type of dimensions",
        Union{Symbol, AbstractVector{Symbol}}, got))

