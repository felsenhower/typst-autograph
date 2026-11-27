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
                    marks: "-solid", // Note: There is currently no edge-marks in fletcher. There should though :)
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

#let diagram(
    axes: (ltr, ttb),
    graph-options: auto,
    ..args,
) = {
    let graph-options = if graph-options == auto {
        (engine: "dot",)
    } else {
        graph-options
    }
    if type(graph-options) != dictionary {
        panic("Graph options must be auto or a dictionary.")
    }
    let engine = graph-options.at("engine", default: "dot")
    if not allowed-engines.contains(engine) {
        panic("Engine \"" + engine + "\" is not allowed. Allowed engines are " + repr(allowed-engines))
    }
    let (style: graph-style, layout: layout-options) = split-graph-options(graph-options)
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
