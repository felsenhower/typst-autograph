#import "./dependencies.typ": testyfy, fletcher
#import "./node.typ": is-autograph-node
#import "./edge.typ": is-autograph-edge
#import "./elements.typ": get-value, extend-element

#let check-nodes(elements) = {
    testyfy.typeof(elements, array)
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
    testyfy.typeof(elements, array)
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

#let get-node-measurements(elements, diagram-args) = {
    testyfy.typeof(elements, array)
    elements.filter(is-autograph-node).map(
        elem => {
            let node = get-value(elem)
            let name = str(node.name)
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
            (name, extend-element(elem, (measurements: measurements)))
        }
    ).to-dict()
}

#let edge-name(index) = {
    testyfy.typeof(index, int)
    "edge-" + str(index)
}

#let get-edge-names(elements) = {
    testyfy.typeof(elements, array)
    elements.enumerate().filter(
        ((i, elem)) => is-autograph-edge(elem)
    ).map(
        ((i, elem)) => {
            (edge-name(i), elem)
        }
    ).to-dict()
}
