#import "./elements.typ": autograph-element, is-autograph-element, get-class
#import "./util.typ": (
    check-is-of-type,
    check-is-of-type-or-auto,
    fill-like-types,
    name-like-types,
    padding-like-types,
    shape-like-types,
    stroke-like-types,
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
    shape: auto,
    fill: auto,
    stroke: auto,
    inset: auto,
    outset: auto,
    extrude: auto,
    layer: auto,
    align: center + horizon,
    /* weight: not supported since we're not using flexigrid. */
    /* enclose: not supported since it's not usable for us. */
    snap: true,
    /* colspan: not supported since we're not using flexigrid. */
    /* rowspan: not supported since we're not using flexigrid. */
    /* in-math: not supported since we're forced to false. */
    debug: auto,
) = {
    check-is-of-type(name, name-like-types)
    if args.pos().len() > 1 {
        panic("only one body can be passed.")
    }
    if args.named().len() > 0 {
        // TODO: Named arguments should be supported, since they're used for node shape arguments.
        // We do however need to filter some unsupported options (rowspan, etc.)
        panic("named arguments are not supported.")
    }
    check-is-of-type-or-auto(shape, shape-like-types)
    check-is-of-type-or-auto(fill, fill-like-types)
    check-is-of-type-or-auto(stroke, stroke-like-types)
    check-is-of-type-or-auto(inset, padding-like-types)
    check-is-of-type-or-auto(outset, padding-like-types)
    check-is-of-type-or-auto(extrude, (array,))
    check-is-of-type-or-auto(layer, int)
    check-is-of-type(align, alignment)
    check-is-of-type(snap, bool)
    check-is-of-type-or-auto(debug, (bool,))
    let body = get-body-from-args(args, name)
    let fletcher-args = (
        shape: shape,
        fill: fill,
        stroke: stroke,
        inset: inset,
        outset: outset,
        extrude: extrude,
        layer: layer,
        align: align,
        snap: snap,
        debug: debug,
    ).pairs().filter(
        ((k, v)) => v != auto
    ).to-dict()
    autograph-element(
        "node",
        (
            name: name,
            body: body,
            args: fletcher-args,
        )
    )
}

#let is-autograph-node(e) = {
    (is-autograph-element(e) and get-class(e) == "node")
}
