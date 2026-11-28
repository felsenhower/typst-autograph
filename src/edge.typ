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
    "snap-method",
    "in-math",
    "path",
)

/// Connects two nodes with an edge. The path of the edge is determined automatically by the layout engine and drawn as a Bézier curve.
///
/// Both `tail` and `head` must refer to nodes that are defined with @node in the same @diagram. Multiple edges between the same pair of nodes are allowed. Edges are directed by default, i.e. they have an arrow at the `head`.
///
/// Unlike `fletcher.edge`, no positional arguments other than `tail` and `head` can be passed. In particular, edge marks have to be given via the `marks` argument, and labels are not supported yet. The arguments `corner-radius`, `label`, `label-pos`, `label-side`, `label-sep`, `label-angle`, `label-anchor`, `snap-to`, `in-math`, and `path` are not supported either.
///
/// All other named arguments are passed on to `fletcher.edge`, for example `stroke`, `marks`, `bend`, and `extrude`. Please refer to the #link("https://fletcher-package.github.io/manual/edges.html")[fletcher manual] for details. Arguments that are given here take precedence over all @styling[graph styles].
///
/// ```example
/// #diagram(
///   node(<a>), node(<b>), node(<c>),
///   edge(<a>, <b>),
///   edge(<a>, <c>, stroke: blue + 2pt),
///   edge(<b>, <c>, stroke: red, marks: (none, none)),
/// )
/// ```
///
/// - tail (str, label): The name of the node where the edge starts.
/// - head (str, label): The name of the node where the edge ends.
/// - ..args (arguments): Named arguments that are passed on to `fletcher.edge`.
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
            panic("Edge argument \"" + argname + "\" is not supported.")
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
