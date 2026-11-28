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

/// Places a node in the graph. The position of the node is determined automatically by the layout engine.
///
/// This function closely resembles `fletcher.node`. The differences are:
/// - The `name` is required and is used to refer to the node from @edge.
/// - The node position can not be passed.
/// - The body is passed as an optional positional argument. If it is omitted (or `auto`), the node name is used as the body. If it is `none`, the node is a small empty box.
/// - The arguments `enclose`, `weight`, `colspan`, `rowspan`, and `in-math` are not supported.
///
/// All other named arguments are passed on to `fletcher.node`, for example `shape`, `fill`, `stroke`, `inset`, `outset`, and `extrude`. Please refer to the #link("https://fletcher-package.github.io/manual/nodes.html")[fletcher manual] for details. Arguments that are given here take precedence over all @styling[graph styles].
///
/// ```example
/// #diagram(
///   node(<a>),
///   node(<b>, [Body], shape: "rect", fill: orange.lighten(70%)),
///   node(<c>, none),
///   edge(<a>, <b>),
///   edge(<a>, <c>),
/// )
/// ```
///
/// - name (str, label): The unique name of the node. Strings and labels are interchangeable, i.e. `<foo>` and `"foo"` refer to the same node.
/// - ..args (content, arguments): An optional body for the node, followed by named arguments that are passed to `fletcher.node`.
#let node(
    name,
    ..args,
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
