#
# Dimensions & Factors IO
#
# Printing and stuff

show(io::IO, d::Dimension) =
    print(io, name(d), ":  ", values(d), " (", length(d), ")")

show(io::IO, d::RangeDimension) =
    print(io, name(d), ":  ", repr(first(d)), ":", repr(step(d)), ":",
            repr(last(d)), " (", repr(length(d)), ")")

show(io::IO, d::UnitDimension) =
    print(io, name(d), ":  ", repr(first(d)), ":", repr(last(d)),
            " (", repr(length(d)), ")")

show(io::IO, d::CartesianDimension) =
    print(io, name(d), ":  1:", repr(last(d)))

Base.mimewritable(::MIME"text/html", d::Dimension) = false
show(io::IO, a::MIME"text/html", d::Dimension) =
        print(io, replace(replace(repr(d), "\n", "<br>"),
                "  ", "&emsp;"))

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
Base.show(io::IO, a::MIME"text/html", ϕ::Factor) =
        show(io, a, DataFrame(ϕ))

