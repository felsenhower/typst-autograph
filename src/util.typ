#import "dependencies.typ": testyfy

#let check-is-of-type(value, type-or-types) = {

    // I heard you like type-checks
    // So I added a type-check to your type-check
    testyfy.type-one-of(type-or-types, (type, array))

    if type(type-or-types) == type {
        testyfy.typeof(value, type-or-types)
    } else {
        testyfy.nonempty(type-or-types)
        testyfy.eltype(type-or-types, type)
        testyfy.type-one-of(value, type-or-types)
    }
}

#let check-is-of-type-or-auto(value, type-or-types) = {
    check-is-of-type(value, (type(auto), type-or-types).flatten())
}
