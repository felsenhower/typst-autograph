#import "./dependencies.typ": fletcher, cetz
#import "./elements.typ": get-value
#import "./node.typ": is-autograph-node
#import "./edge.typ": is-autograph-edge
#import "./paths.typ": replace-bounds, bezier-segments
#import "./point.typ": point-to-array
#import "./layout.typ": check-nodes, check-edges, make-node-measurements, make-layout
#import "./style.typ": (
    split-graph-options,
    make-graph-style,
    effective-node-args,
    effective-edge-args,
)

#let allowed-engines = (
    "circo",
    "dot",
    "fdp",
    "neato",
    "osage",
    "sfdp",
    "twopi"
)

#let render-elements(elements, graph-style) = {
    elements.map(
        elem => {
            if is-autograph-node(elem) {
                let node = get-value(elem)
                let name = node.name
                fletcher.node(
                    point-to-array(node.position),
                    name: name,
                    ..effective-node-args(node, graph-style),
                    node.body
                )
            } else if is-autograph-edge(elem) {
                let edge = get-value(elem)
                // Function for custom edge
                // https://fletcher-package.github.io/manual/edges.html#custom-edge
                let path-fun = points => {
                    let segments = bezier-segments(points)
                    cetz.draw.merge-path({
                        for (start, ctrl-start, ctrl-end, end) in segments {
                            cetz.draw.bezier(start, end, ctrl-start, ctrl-end)
                        }
                    })
                }
                let points = edge.points.map(point-to-array)
                // Replace the tail and head with the fletcher nodes.
                // In most cases, this won't make a noticable difference.
                // In rare cases, this makes for a nicer layout.
                let points = replace-bounds(
                    points,
                    edge.tail,
                    edge.head
                )
                fletcher.edge(
                    ..points,
                    snap-to: (edge.tail, edge.head),
                    snap-method: "trim",
                    ..effective-edge-args(edge, graph-style),
                    path: path-fun
                )
            } else {
                elem
            }
        }
    )
}

/// Draws a graph with automatic layout. This function is a wrapper around `fletcher.diagram` (which can also be used as a drop-in replacement).
/// 
/// To define the graph, use @node and @edge elements within the body of the diagram. They can be freely mixed with fletcher elements (e.g. `fletcher.node` and `fletcher.edge`). See @mixing for details. The autograph elements are laid out by Graphviz and the fletcher elements are passed through unchanged. The order of the elements is preserved, even between autograph and fletcher elements. This determines the drawing order of the elements. The node labels of the autograph nodes can be used for positioning of fletcher elements. The flexigrid layout of the fletcher elements is not influenced by the autograph elements since they use absolute coordinates.
/// 
/// All named arguments other than `graph-options` are passed on to `fletcher.diagram`. In particular, `node-*` and `edge-*` arguments set the @styling[default style] of the nodes and edges.
///
/// ```example
/// #diagram(
///   node-shape: "rect",
///   graph-options: (rankdir: ltr),
///   node(<a>), node(<b>), node(<c>),
///   edge(<a>, <b>),
///   edge(<a>, <c>),
/// )
/// ```
///
/// - axes (array): The directions of the coordinate axes, as in `fletcher.diagram`. Note that this only influences how fletcher interprets coordinates, not how the graph is laid out (see @rankdir).
/// - graph-options (auto, dictionary): Options for the graph. This is a dictionary that may contain the following entries (see @graph-options for details):
///   - `engine` (str): The Graphviz layout engine. One of `"circo"`, `"dot"`, `"fdp"`, `"neato"`, `"osage"`, `"sfdp"`, and `"twopi"`. Default: `"dot"`.
///   - `rankdir` (direction): The direction in which the graph is laid out. One of `ttb`, `btt`, `ltr`, and `rtl`. Default: `ttb`.
///   - Any `node-*` or `edge-*` style argument. These only apply to autograph nodes and edges and take precedence over the diagram arguments.
/// - ..args (arguments): The elements of the diagram, followed by named arguments that are passed on to `fletcher.diagram`.
#let diagram(
    axes: (ltr, ttb),
    graph-options: auto,
    ..args,
) = {
    let graph-options = if graph-options == auto { (:) } else { graph-options }
    if type(graph-options) != dictionary {
        panic("Graph options must be auto or a dictionary.")
    }
    let (style: graph-style, layout: layout-options) = split-graph-options(graph-options)
    let engine = layout-options.engine
    if not allowed-engines.contains(engine) {
        panic("Engine \"" + engine + "\" is not allowed. Allowed engines are " + repr(allowed-engines))
    }
    let diagram-args = args.named()
    let graph-style = make-graph-style(diagram-args, graph-style)
    let elements = args.pos().flatten()
    check-nodes(elements)
    check-edges(elements)
    context {
        let elements = make-node-measurements(elements, graph-style)
        let elements = make-layout(elements, layout-options)
        let rendered-elements = render-elements(elements, graph-style)
        fletcher.diagram(
            axes: axes,
            ..diagram-args,
            rendered-elements
        )
    }
}

#let panic-on-illegal-engine() = {
    diagram(graph-options: (engine: "nop",))
}
