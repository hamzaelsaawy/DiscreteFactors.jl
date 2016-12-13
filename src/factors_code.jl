type Factor{D<:Dimension, V}
    dimensions::Vector{D}
    v::Array{V}

    function Factor(dimensions::Vector{D}, v::Array)
        if length(dimensions) != ndims(v)
            error("v must have as many dimensions as dimensions")
        end

        if !allunique(map(name, dimensions))
            error("Dimension names must be unique")
        end

        new(dimensions, v)
    end
end

Factor{D<:Dimension, V}(dimensions::Vector{D}, v::Array{V}) =
    Factor{D, V}(dimensions, v)

###############################################################################
#                   IO Stuff

Base.mimewritable(::MIME"text/html", ft::Factor) = true

function Base.show(io::IO, ft::Factor)
    for d in ft.dimensions
        print("\t")
        println(d)
    end
end
Base.show(io::IO, a::MIME"text/html", ft::Factor) = show(io, ft)

