#import "./elements.typ": autograph-element, is-autograph-element, get-class
#import "./util.typ": (
    check-is-of-type,
    check-is-of-type-or-auto,
    name-like-types,
)

#let unsupported-args = (
    "corner-radius",
    "label",
    "label-pos",
    "label-side",
    "label-sep",
    "label-angle",
    "label-anchor",
    "snap-to",
    "snap-mathod",
    "in-math",
    "path",
)

/// Connect two nodes with an edge
#let edge(
    tail,
    head,
    ..args,
) = {
    check-is-of-type(tail, name-like-types)
    check-is-of-type(head, name-like-types)
    if args.pos().len() > 0 {
        panic("No further positional arguments are supported.")
    }
    for argname in unsupported-args {
        if args.named().keys().contains(argname) {
            panic("Node argument \"" + argname + "\" is not supported.")
        }
    }
    autograph-element(
        "edge",
        (
            tail: tail,
            head: head,
            args: args.named(),
        )
    )
}

#let is-autograph-edge(e) = {
    (is-autograph-element(e) and get-class(e) == "edge")
}
