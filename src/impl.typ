#import "./dependencies.typ": fletcher, cetz, diagraph-layout
#import "./elements.typ": get-value, extend-element
#import "./node.typ": node, is-autograph-node
#import "./edge.typ": edge, is-autograph-edge
#import "./paths.typ": replace-bounds, bezier-segments
#import "./point.typ": subtract-points, point-to-array

#let diagram(
  engine: "dot",
  ..args,
) = context {
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
  let (nodes, edges) = {
    let nodes = (:)
    let edges = (:)
    for (i, elem) in elements.enumerate() {
      if is-autograph-node(elem) {
        let node = get-value(elem)
        let name = str(node.name)
        if nodes.keys().contains(name) {
          panic("Duplicate node \"" + name + "\".")
        }
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
        nodes.insert(name, extend-element(elem, (measurements: measurements)))
      } else if is-autograph-edge(elem) {
        let edge = get-value(elem)
        let tail = str(edge.tail)
        if not nodes.keys().contains(tail) {
          panic("Node with name \"" + tail + "\" has not been defined.")
        }
        let head = str(edge.head)
        if not nodes.keys().contains(head) {
          panic("Node with name \"" + head + "\" has not been defined.")
        }

        edges.insert("edge-" + str(i), elem)
      }
    }
    (nodes, edges)
  }
  let (nodes, edges) = {
    if nodes.len() > 0 {
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
      assert(not layout.errored)
      let node-positions = layout.nodes.map(
        (node) => {
          (node.name, (
            x: node.x,
            y: node.y
          ))
        }
      ).to-dict()
      // We guarantee that the first node that was defined will be at position (0,0).
      // To do so, we offset all positions by the first position.
      let position-offset = node-positions.values().at(0)
      let node-positions = node-positions.pairs().map(
        ((name, pos)) => (name, subtract-points(pos, position-offset))
      ).to-dict()
      let nodes = nodes.pairs().map(
        ((name, elem)) => {
          let node = get-value(elem)
          (name, extend-element(elem, (position: node-positions.at(name))))
        }
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
      let edges = edges.pairs().map(
        ((name, elem)) => {
          let edge = get-value(elem)
          (name, extend-element(elem, (points: edge-paths.at(name))))
        }
      ).to-dict()
      (nodes, edges)
    } else {
      (nodes, edges)
    }    
  }
  let rendered-elements = elements.enumerate().map(
    ((i, elem)) => {
      if is-autograph-node(elem) {
        let name = str(get-value(elem).name)
        let node = get-value(nodes.at(name))
        fletcher.node(
          point-to-array(node.position),
          name: name,
          ..node.args,
          node.body
        )
      } else if is-autograph-edge(elem) {
        let name = "edge-" + str(i)
        let edge = get-value(edges.at(name))
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
          ..edge.args,
          path: path-fun
        )
      } else {
        elem
      }
    }
  )
  fletcher.diagram(
    ..diagram-args,
    rendered-elements
  )
}
