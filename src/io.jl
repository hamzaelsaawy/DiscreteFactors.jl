#
# Dimensions & Factors IO
#
# Printing and stuff

function show(io::IO, d::Dimension)
    println(io, name(d), ":")
    print(io, "\t", values(d), " (", length(d), ")")
end

function show(io::IO, d::RangeDimension)
    println(io, name(d), ":")
    print(io, "\t", first(d), ":", step(d), ":", last(d))
end

Base.mimewritable(::MIME"text/html", d::Dimension) = true
show(io::IO, a::MIME"text/html", d::Dimension) =
        print(io, replace(replace(repr(d), "\n", "<br>"),
                "\t", "&emsp;&emsp;&emsp;"))
#=
function Base.show(io::IO, ϕ::Factor)
    print(io, "$(length(ϕ)) instantiations:")
    for (d, s) in zip(ϕ.dimensions, size(ϕ))
        println(io, "")
        print(io, "\t", d, " (", s, ")")
    end
end

Base.mimewritable(::MIME"text/html", ϕ::Factor) = true
Base.show(io::IO, a::MIME"text/html", ϕ::Factor) =
        show(io, a, DataFrame(ϕ))
=#
