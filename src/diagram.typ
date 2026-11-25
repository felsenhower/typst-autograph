#import "./dependencies.typ": fletcher, cetz
#import "./elements.typ": get-value
#import "./node.typ": is-autograph-node
#import "./edge.typ": is-autograph-edge
#import "./paths.typ": replace-bounds, bezier-segments
#import "./point.typ": point-to-array
#import "./layout.typ": check-nodes, check-edges, make-node-measurements, make-layout

#let allowed-engines = (
    "circo",
    "dot",
    "fdp",
    "neato",
    "osage",
    "sfdp",
    "twopi"
)

#let render-elements(elements) = {
    elements.map(
        elem => {
            if is-autograph-node(elem) {
                let node = get-value(elem)
                let name = node.name
                fletcher.node(
                    point-to-array(node.position),
                    name: name,
                    ..node.args,
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
                    marks: "-solid",
                    snap-to: (edge.tail, edge.head),
                    snap-method: "trim",
                    ..edge.args,
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
    engine: "dot",
    ..args,
) = {
    if not allowed-engines.contains(engine) {
        panic("Engine \"" + engine + "\" is not allowed. Allowed engines are " + repr(allowed-engines))
    }
    let default-args = (
        node-shape: "ellipse",
        node-stroke: 1pt + black,
        edge-stroke: 1pt,
        mark-scale: 125%,
        node-inset: 1.5em,
    )
    let diagram-args = args.named()
    for (k, v) in default-args.pairs() {
        if not diagram-args.keys().contains(k) {
            diagram-args.insert(k, v)
        }
    }
    let elements = args.pos().flatten()
    check-nodes(elements)
    check-edges(elements)
    context {
        let elements = make-node-measurements(elements, diagram-args)
        let elements = make-layout(elements, engine)
        let rendered-elements = render-elements(elements)
        fletcher.diagram(
            axes: axes,
            ..diagram-args,
            rendered-elements
        )
    }
}

#let panic-on-illegal-engine() = {
    diagram(engine: "nop")
}
