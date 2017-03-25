#
# Dimensions & Factors IO
#
# Printing and stuff

####################################################################################################
#                                   Dimensions
Base.show(io::IO, d::Dimension) =
    print(io, name(d), ":  ", _support_repr(values(d)))

_support_repr(v::AbstractVector) = repr(v) * " (" * repr(length(v)) * ")"

_support_repr(v::Range) =
    repr(first(v)) * ":" * repr(step(v)) * ":" * repr(last(v)) * " (" * repr(length(v)) * ")"

_support_repr(v::UnitRange) =
    repr(first(v)) * ":" * repr(last(v)) * " (" * repr(length(v)) * ")"

_support_repr(v::Base.OneTo) = "1:" * repr(last(v))

Base.mimewritable(::MIME"text/html", d::Dimension) = false
Base.show(io::IO, a::MIME"text/html", d::Dimension) =
        print(io, replace(replace(repr(d), "\n", "<br>"), "  ", "&emsp;"))

####################################################################################################
#                                   Factors
function Base.show(io::IO, ϕ::Factor)
    if length(ϕ) > 1
        print(io, length(ϕ), " instantiations:")
        for d in ϕ.dimensions
            println(io, "")
            print(io, "\t", d)
        end
    else
        print(io, "1 instantiation: ", ϕ.potential[1])
    end
end

Base.mimewritable(::MIME"text/html", ϕ::Factor) = false
Base.show(io::IO, a::MIME"text/html", ϕ::Factor) = show(io, a, DataFrame(ϕ))
