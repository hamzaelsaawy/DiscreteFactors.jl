#
# Dimensions & Factors IO
#
# Printing and stuff


Base.mimewritable(::MIME"text/html", d::Dimension) = true

function show(io::IO, d::Dimension)
    println(io, name(d), ":")
    print(io, "  ", values(d), " (", length(d), ")")
end
show(io::IO, a::MIME"text/html", d::Dimension) = show(io, d)

function show(io::IO, d::AbstractRangeDimension)
    println(io, name(d), ":")
    print(io, "  ", first(d), ":", step(d), ":", last(d))
end
show(io::IO, a::MIME"text/html", d::AbstractRangeDimension) = show(io, d)

#Base.show(io::IO, d::CartesianDimension) =
#    print(io, "$(d.name): 1:$(last(d))")
#Base.show(io::IO, a::MIME"text/html", d::CartesianDimension) = show(io, d)
#=
function Base.show(io::IO, ϕ::Factor)
    print(io, "$(length(ϕ)) instantiations:")
    for (d, s) in zip(ϕ.dimensions, size(ϕ))
        println(io, "")
        print(io, "  $d ($s)")
    end
end

Base.mimewritable(::MIME"text/html", ϕ::Factor) = true
Base.show(io::IO, a::MIME"text/html", ϕ::Factor) =
        show(io, a, DataFrame(ϕ))
=#
