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

// Replaces the start and end points of a list of Bézier segements.
// For example: 
// ((p0, p1, p2, p3), (p3, p4, p5, p6)) -> ((new-start, p1, p2, p3), (p3, p4, p5, new-end))
// or
// ((p0, p1, p2, p3)) -> ((new-start, p1, p2, new-end))
#let replace-bezier-bounds(segments, new-start, new-end) = {
  let replace-start(segments, replacement) = (
    (
      replacement,
      ..segments.first().slice(1),
    ),
    ..segments.slice(1),
  )
  let replace-end(segments, replacement) = (
    ..segments.slice(0, -1),
    (
      ..segments.last().slice(0, -1),
      replacement,
    ),
  )
  replace-start(
    replace-end(
      segments,
      new-end
    ),
    new-start
  )
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
  let fletcher-elements = args.pos().flatten().filter(e => not is-autograph-elem(e))
  let autograph-elements = args.pos().flatten().filter(is-autograph-elem)
  let (rendered-nodes, edges, layout-edges) = {
    if autograph-elements.len() > 0 {
      let nodes = autograph-elements.filter(is-autograph-node).map(
        e => (str(e.value.name), e)
      ).to-dict()
      let edges = autograph-elements.filter(is-autograph-edge).enumerate().map(
        ((i, e)) => ("edge-" + str(i), e)
      ).to-dict()
      let node-dimensions = nodes.pairs().map(
        ((name, node)) => {
          let measurements = measure(
            fletcher.diagram(
              ..diagram-args,
              fletcher.node(
                (0,0), // Let's hope that this keeps people from manually supplying a position in the node args
                ..node.value.args,
                node.value.body
              )
            )
          )
          (name, measurements)
        }
      ).to-dict()
      assert(nodes.keys() == node-dimensions.keys())
      let layout = diagraph-layout.layout-graph(
        engine: engine,
        directed: true,
        ..node-dimensions.pairs().map(
          ((name, measurements)) => {
            diagraph-layout.node(
              name,
              width: measurements.width,
              height: measurements.height
            )    
          }
        ),
        ..edges.pairs().map(
          ((name, edge)) => {
            diagraph-layout.edge(
              str(edge.value.tail),
              str(edge.value.head),
              name: name,
            )
          }
        ),
      )
      assert(not layout.errored)
      let node-positions = layout.nodes.map(
        (node) => {
          (node.name, (node.x, node.y))
        }
      ).to-dict()
      // diagraph-layout does not guarantee that the input and output order of the nodes is identical.
      // We ensure this by explicitly re-ordering the dict.
      let node-positions = nodes.keys().map(
        name => (name, node-positions.at(name))
      ).to-dict()
      assert(nodes.keys() == node-positions.keys())
      // We guarantee that the first node that was defined will be at position (0,0).
      // To do so, we offset all positions by the first position.
      let position-offset = node-positions.values().at(0)
      let node-positions = node-positions.pairs().map(
        ((name, (x,y))) => {
          let (dx, dy) = position-offset
          (name, (x - dx, y - dy))
        }
      ).to-dict()
      let layout-edges = layout.edges.map(
        (edge) => {
          (edge.name, (
            tail: edge.tail,
            head: edge.head,
            points: edge.points
          ))
        }
      ).to-dict()
      // diagraph-layout does not guarantee that the input and output order of the edges is identical.
      // We ensure this by explicitly re-ordering the dict.
      let layout-edges = edges.keys().map(
        name => (name, layout-edges.at(name))
      ).to-dict()
      assert(edges.keys() == layout-edges.keys())
      let layout-edges = layout-edges.pairs().map(
        ((name, edge)) => {
          let points = edge.points.map(
            // We are again using the position-offset, just like with the node-positions:
            point => {
              let (dx, dy) = position-offset
              (point.x - dx, point.y - dy)
            }
          )
          (name, 
            (
              head: edge.head,
              tail: edge.tail,
              points: points,
            ),
          )
        }
      ).to-dict()
      let rendered-nodes = {
        for ((name, node), (x, y)) in nodes.pairs().zip(node-positions.values()) {
          fletcher.node(
            (x, y),
            name: node.value.name,
            ..node.value.args,
            node.value.body
          )
        }
      }
      (rendered-nodes, edges, layout-edges)
    } else {
      ((), (), ())
    }
  }
  fletcher.diagram(
    ..diagram-args,
    rendered-nodes,
    for (edge, layout-edge) in edges.values().zip(layout-edges.values()) {
      assert(str(edge.value.tail) == layout-edge.tail)
      assert(str(edge.value.head) == layout-edge.head)
      // Function for custom edge
      // https://fletcher-package.github.io/manual/edges.html#custom-edge
      let path-fun = points => {
        let segments = bezier-segments(points)
        // Replace the tail and head with the fletcher nodes.
        // In most cases, this won't make a noticable difference.
        // In rare cases, this makes for a nicer layout.
        let segments = replace-bezier-bounds(
          segments,
          edge.value.tail,
          edge.value.head
        )
        cetz.draw.merge-path({
          for (start, ctrl-start, ctrl-end, end) in segments {
            cetz.draw.bezier(start, end, ctrl-start, ctrl-end)
          }
        })
      }
      fletcher.edge(
        ..layout-edge.points,
        marks: "-solid",
        ..edge.value.args,
        path: path-fun
      )
    },
    fletcher-elements,
  )
}
