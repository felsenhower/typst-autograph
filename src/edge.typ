#import "./elements.typ": autograph-element, is-autograph-element, get-class
#import "./util.typ": (
    check-is-of-type,
    check-is-of-type-or-auto,
    name-like-types,
    stroke-like-types,
)

/// Connect two nodes with an edge
#let edge(
    tail,
    head,
    ..args,
    stroke: auto,
    dash: auto,
    extrude: auto,
    shift: 0,
    /* corner-radius: *currently* not supported since it's not applied to bezier curves. However, if we supported `splines=ortho`, we could pass this to the `radius` attribute of the edge. */
    marks: (),
    mark-scale: auto,
    /* label: *currently* unsupported, but planned. */
    /* label-pos: currently unsupported */
    /* label-side: currently unsupported */
    /* label-sep: currently unsupported */
    /* label-angle: currently unsupported */
    /* label-anchor: currently unsupported */
    /* snap-to: unsupported, since we *always* snap to the two the tail and head */
    /* snap-method: unsupported, since only "trim" makes sense here. */
    outset: auto,
    shorten: 0,
    name: none,
    decorate: auto,
    layer: auto,
    crossing: false,
    crossing-fill: auto,
    crossing-thickness: auto,
    /* in-math: not supported since we're forced to false. */
    debug: auto,
) = {
    check-is-of-type(tail, name-like-types)
    check-is-of-type(head, name-like-types)
    /*
        TODO: Parse positional arguments.
    */
    check-is-of-type-or-auto(stroke, stroke-like-types)
    check-is-of-type-or-auto(dash, (type(none), str, array, dictionary))
    check-is-of-type-or-auto(extrude, (int, float, length, array))
    check-is-of-type(shift, (int, float, length))
    check-is-of-type(marks, (str, array))
    check-is-of-type-or-auto(mark-scale, (int, float, relative))
    check-is-of-type-or-auto(outset, (int, float, length, array))
    check-is-of-type-or-auto(shorten, (int, float, length, array))
    check-is-of-type-or-auto(name, (type(none), ..name-like-types)) // This should *not* be passed to graphviz.
    check-is-of-type-or-auto(decorate, (str, dictionary))
    check-is-of-type-or-auto(layer, int)
    check-is-of-type(crossing, bool)
    check-is-of-type-or-auto(crossing-fill, color)
    check-is-of-type-or-auto(crossing-thickness, (int, float, length))
    check-is-of-type-or-auto(debug, (bool,))
    let marks = {
        if marks == () {
            auto
        } else {
            marks
        }
    }
    let fletcher-args = args.named() + (
        stroke: stroke,
        dash: dash,
        extrude: extrude,
        shift: shift,
        marks: marks,
        mark-scale: mark-scale,
        outset: outset,
        shorten: shorten,
        name: name,
        decorate: decorate,
        layer: layer,
        crossing: crossing,
        crossing-fill: crossing-fill,
        crossing-thickness: crossing-thickness,
        debug: debug
    ).pairs().filter(
        ((k, v)) => v != auto
    ).to-dict()
    autograph-element(
        "edge",
        (
            tail: tail,
            head: head,
            args: fletcher-args,
        )
    )
}

#let is-autograph-edge(e) = {
    (is-autograph-element(e) and get-class(e) == "edge")
}
