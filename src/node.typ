#import "./elements.typ": autograph-element, is-autograph-element, get-class
#import "./util.typ": (
    check-is-of-type,
    check-is-of-type-or-auto,
    name-like-types,
)

#let get-body-from-args(args, name) = {
    let pos = args.pos()
    if pos.len() == 0 {
        return str(name)
    }
    let body = pos.at(0)
    if body == auto {
        return str(name)
    }
    if body == none {
        return box(width: 0.85em, height: 0.85em)
    }
    body
}

#let unsupported-args = (
    "weight",
    "enclose",
    "colspan",
    "rowspan",
    "in-math"
)

/// Place a node in a graph
/// This function closely resembles `fletcher.node`.
/// Some differences are:
/// - `name` is required
/// - the node position can not be passed.
/// - the body is passed as a positional arg (the node name will be used if no body is passed).
/// - `enclose`, `weight`, `colspan`, `rowspan`, and `in-math` are not supported.
/// For all other options, please refer to the documentation of `fletcher.node`.
#let node(
    name,
    ..args, // optional positional argument body
) = {
    check-is-of-type(name, name-like-types)
    if args.pos().len() > 1 {
        panic("No further positional arguments are supported.")
    }
    let body = get-body-from-args(args, name)
    for argname in unsupported-args {
        if args.named().keys().contains(argname) {
            panic("Node argument \"" + argname + "\" is not supported.")
        }
    }
    autograph-element(
        "node",
        (
            name: name,
            body: body,
            args: args.named(),
        )
    )
}

#let is-autograph-node(e) = {
    (is-autograph-element(e) and get-class(e) == "node")
}

#let panic-on-illegal-arg() = {
    node(<foo>, weight: 5)
}
