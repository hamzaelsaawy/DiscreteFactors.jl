#
# Errors
#
# All the errors that can be thrown

singleton_dimension_error(l) = throw(ArgumentError("Dimension is singleton " *
            "with length $(l)"))

not_enough_dims_error() = throw(ArgumentError("`potential` must have as " *
            "many dimensions as `dimensions`"))

non_unique_states_error() = throw(ArgumentError("States must be unique"))

invalid_dim_sizes() = throw(ArgumentError("Dimension lengths must match " *
            "shape of `potential`"))

non_unique_dims_error() = throw(ArgumentError("Dimensions must be unique"))

not_in_factor_error(name) = throw(ArgumentError(name * " is not " *
            "a valid dimension"))

invalid_dims_error(func, got) = throw(TypeError(func, "type of dimensions",
        NodeNameUnion, got))

