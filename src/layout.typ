#import "./dependencies.typ": fletcher, diagraph-layout
#import "./node.typ": is-autograph-node
#import "./edge.typ": is-autograph-edge
#import "./elements.typ": get-value, extend-element
#import "./point.typ": subtract-points
#import "./util.typ": check-is-of-type

#let check-nodes(elements) = {
    check-is-of-type(elements, array)
    let names = ()
    for elem in elements.filter(is-autograph-node) {
        let name = str(get-value(elem).name)
        if names.contains(name) {
            panic("Duplicate node \"" + name + "\".")()
        }
        names.push(name)
    }
}

#let check-edges(elements) = {
    check-is-of-type(elements, array)
    let node-names = elements.filter(is-autograph-node).map(
        e => str(get-value(e).name)
    )
    for elem in elements.filter(is-autograph-edge) {
        let edge = get-value(elem)
        let tail = str(edge.tail)
        if not node-names.contains(tail) {
          panic("Node with name \"" + tail + "\" has not been defined.")
        }
        let head = str(edge.head)
        if not node-names.contains(head) {
          panic("Node with name \"" + head + "\" has not been defined.")
        }
    }
}

#let make-node-measurements(elements, diagram-args) = {
    check-is-of-type(elements, array)
    elements.map(
        elem => {
            if is-autograph-node(elem) {
                let node = get-value(elem)
                let measurements = measure(
                    fletcher.diagram(
                        ..diagram-args,
                        fletcher.node(
                            (0,0), // Let's hope that this keeps people from manually supplying a position in the node args
                            ..node.args,
                            node.body
                        )
                    )
                )
                extend-element(elem, (measurements: measurements))
            } else {
                elem
            }
        }
    )
}

#let make-layout(elements, engine) = {
    let generic-element-name(index) = "elem-" + str(index)
    let edge-name(index) = "edge-" + str(index)
    let named-elements = elements.enumerate().map(
        ((i, elem)) => {
            if is-autograph-node(elem) {
                (str(get-value(elem).name), elem)
            } else if is-autograph-edge(elem) {
                (edge-name(i), elem)
            } else {
                (generic-element-name(i), elem)
            }
        }
    ).to-dict()
    let nodes = named-elements.pairs().filter(
        ((name, elem)) => is-autograph-node(elem)
    ).to-dict()
    if nodes.len() == 0 {
        // Nothing to layout, return unchanged
        return elements
    }
    let edges = named-elements.pairs().filter(
        ((name, elem)) => is-autograph-edge(elem)
    ).to-dict()
    let layout = diagraph-layout.layout-graph(
        engine: engine,
        directed: true,
        ..nodes.pairs().map(
            ((name, elem)) => {
                let node = get-value(elem)
                let measurements = node.measurements
                diagraph-layout.node(
                    name,
                    width: measurements.width,
                    height: measurements.height,
                )
            }
        ),
        ..edges.pairs().map(
            ((name, elem)) => {
                let edge = get-value(elem)
                diagraph-layout.edge(
                    str(edge.tail),
                    str(edge.head),
                    name: name,
                )
            }
        ),
    )
    if (layout.errored) {
        panic("Unable to create layout for graph!")
    }
    let node-positions = layout.nodes.map(
        (node) => {
            (node.name, (
                x: node.x,
                y: node.y
            ))
        }
    ).to-dict()
    // We guarantee that the first node that was defined will be at position (0,0).
    // To do so, we offset all positions by the position of the first node that was defined.
    let first-node-name = nodes.keys().at(0)
    let position-offset = node-positions.at(first-node-name)
    let node-positions = node-positions.pairs().map(
        ((name, pos)) => (name, subtract-points(pos, position-offset))
    ).to-dict()
    let edge-paths = layout.edges.map(
        (edge) => {
            (edge.name, edge.points)
        }
    ).to-dict()
    let edge-paths = edge-paths.pairs().map(
        ((name, edge)) => {
            let points = edge.map(
                point => subtract-points(point, position-offset)
            )
            (name, points)
        }
    ).to-dict()
    elements.enumerate().map(
        ((i, elem)) => {
            if is-autograph-node(elem) {
                let name = str(get-value(elem).name)
                extend-element(elem, (position: node-positions.at(name)))
            } else if is-autograph-edge(elem) {
                let name = edge-name(i)
                extend-element(elem, (points: edge-paths.at(name)))
            } else {
                elem
            }
        }
    )
}
