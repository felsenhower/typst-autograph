#import "@preview/fletcher:0.6.0" as fletcher
#import "diagraph-layout/lib.typ" as diagraph-layout
#import fletcher: cetz


#let node(name, ..args) = {
  assert(args.pos().len() <= 1)
  let body = {
    let pos = args.pos()
    if pos.len() == 0 {
      str(name)
    } else {
      let body = pos.at(0)
      if body == none {
        body = box(width: 0.85em, height: 0.85em)
      }
      body
    }
  }
  metadata((
    class: "autograph-node",
    name: name,
    body: body,
    args: args.named(),
  ))
}

#let edge(tail, head, ..args) = {
  assert(args.pos().len() == 0)
  metadata((
    class: "autograph-edge",
    tail: tail,
    head: head,
    args: args.named(),
  ))
}

// This function transforms a list of Bézier control points to a list of Bézier segments.
// A single Bézier segment has 4 control points: the start, two points that determine the curvature, and the end.
// When the curve consists of only one segment, the length is 4,
// and for more than one segment, the length must be 7, 10, 13, 16, ...
// For example, when points = (p0, p1, p2, p3, p4, p5, p6, p7, p8, p9),
// we get: 
// ((p0, p1, p2, p3), (p3, p4, p5, p6), (p6, p7, p8, p9))
#let bezier-segments(points) = {
  assert(calc.rem(points.len() - 1, 3) == 0)
  let segments = ()
  let i = 0
  while i + 3 < points.len() {
    segments.push(points.slice(i, i + 4))
    i += 3
  }
  segments
}

#let replace-bounds(points, new-start, new-end) = {
  assert(points.len() >= 2)
  (new-start, ..points.slice(1, -1), new-end)
}

#let is-autograph-elem(e) = {
  if type(e) != content {
    return false
  }
  let fields = e.fields()
  let value = fields.at("value", default: none)
  if type(value) != dictionary {
    return false
  }
  let class = value.at("class", default: none)
  if type(class) != str {
    return false
  }
  return class.starts-with("autograph-")
}

#let is-autograph-node(e) = {
  if not is-autograph-elem(e) {
    return false
  }
  return e.value.class == "autograph-node"
}

#let is-autograph-edge(e) = {
  if not is-autograph-elem(e) {
    return false
  }
  return e.value.class == "autograph-edge"
}

#let subtract-points(p1, p2) = {
  (
    x: p1.x - p2.x,
    y: p1.y - p2.y,
  )
}

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
        let node = elem.value
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
        nodes.insert(name, (
          name: node.name,
          body: node.body,
          args: node.args,
          measurements: measurements,
        ))
      } else if is-autograph-edge(elem) {
        let edge = elem.value
        let tail = str(edge.tail)
        if not nodes.keys().contains(tail) {
          panic("Node with name \"" + tail + "\" has not been defined.")
        }
        let head = str(edge.head)
        if not nodes.keys().contains(head) {
          panic("Node with name \"" + head + "\" has not been defined.")
        }
        edges.insert("edge-" + str(i), (
          tail: edge.tail,
          head: edge.head,
          args: edge.args,
        ))
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
          ((name, node)) => {
            let measurements = node.measurements
            diagraph-layout.node(
              name,
              width: measurements.width,
              height: measurements.height,
            )    
          }
        ),
        ..edges.pairs().map(
          ((name, edge)) => {
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
        ((name, node)) => (name, (
          body: node.body,
          args: node.args,
          measurements: node.measurements,
          position: node-positions.at(name)
        ))
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
        ((name, edge)) => (name, (
          tail: edge.tail,
          head: edge.head,
          args: edge.args,
          points: edge-paths.at(name),
        ))
      ).to-dict()
      (nodes, edges)
    } else {
      (nodes, edges)
    }    
  }
  let rendered-elements = elements.enumerate().map(
    ((i, elem)) => {
      if is-autograph-node(elem) {
        let name = str(elem.value.name)
        let node = nodes.at(name)
        fletcher.node(
          (node.position.x, node.position.y),
          name: name,
          ..node.args,
          node.body
        )
      } else if is-autograph-edge(elem) {
        let name = "edge-" + str(i)
        let edge = edges.at(name)
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
        let points = edge.points.map(p => (p.x, p.y))
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
