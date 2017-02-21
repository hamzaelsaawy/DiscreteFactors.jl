#
# Errors
#
# All the errors that can be thrown

empty_support_error() = throw(ArgumentError("Dimension support is empty"))

not_enough_dims_error() = throw(ArgumentError("`potential` must have as " *
            "many dimensions as `dimensions`"))

non_unique_states_error() = throw(ArgumentError("States must be unique"))

invalid_dim_sizes() = throw(ArgumentError("Dimension lengths must match " *
            "shape of `potential`"))

non_unique_dims_error() = throw(ArgumentError("Dimensions must be unique"))

not_in_factor_error(name) = throw(ArgumentError(repr(name) * " is not " *
            "a valid dimension"))

invalid_dims_error(func, got) = throw(TypeError(func, "type of dimensions",
        NodeNameUnion, got))

