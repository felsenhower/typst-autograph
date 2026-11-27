// Style handling for graph elements.
//
// Precedence, from lowest to highest:
//   graph-default-style < diagram args < graph-options < element args
//
// Styles are stored in the format of the fletcher diagram arguments,
// e.g. `node-shape`, `edge-stroke`, `edge-mark-scale`.
// Fletcher's `mark-scale` is accepted as an alias of `edge-mark-scale`.

#let default-mark = (inherit: "solid", size: 12.5)

#let graph-default-style = (
    node-shape: "ellipse",
    node-stroke: 1pt + black,
    node-inset: 1.5em,
    edge-stroke: 1pt,
    edge-marks: (none, default-mark),
)

#let graph-default-layout-options = (
    engine: "dot",
)

#let is-node-style-key(key) = key.starts-with("node-")

#let is-edge-style-key(key) = key.starts-with("edge-") or key == "mark-scale"

#let is-style-key(key) = is-node-style-key(key) or is-edge-style-key(key)

#let normalize-style-key(key) = if key == "mark-scale" { "edge-mark-scale" } else { key }

#let normalize-style(style) = {
    let normalized = (:)
    for (k, v) in style {
        normalized.insert(normalize-style-key(k), v)
    }
    normalized
}

/// Split graph options into style options and the remaining layout options (with defaults).
#let split-graph-options(graph-options) = {
    let style = (:)
    let layout = (:)
    for (k, v) in graph-options {
        if is-style-key(k) {
            style.insert(normalize-style-key(k), v)
        } else {
            layout.insert(k, v)
        }
    }
    (style: style, layout: graph-default-layout-options + layout)
}

/// Style that applies to all elements of the graph, ignoring per-element args.
#let make-graph-style(diagram-args, graph-style) = {
    let diagram-style = normalize-style(
        diagram-args.pairs().filter(((k, v)) => is-style-key(k)).to-dict()
    )
    graph-default-style + diagram-style + graph-style
}

// Strokes combine property-wise (e.g. `red` keeps the inherited thickness), like in fletcher.
#let merge-stroke(base, over) = {
    if over == auto { return base }
    if base == auto or base == none or over == none { return over }
    let (base, over) = (stroke(base), stroke(over))
    let pick(b, o) = if o == auto { b } else { o }
    let merged = (
        paint: pick(base.paint, over.paint),
        thickness: pick(base.thickness, over.thickness),
        cap: pick(base.cap, over.cap),
        join: pick(base.join, over.join),
        dash: pick(base.dash, over.dash),
        miter-limit: pick(base.miter-limit, over.miter-limit),
    ).pairs().filter(((k, v)) => v != auto).to-dict()
    stroke(..merged)
}

#let merge-args(inherited, own) = {
    let merged = inherited + own
    if inherited.keys().contains("stroke") and own.keys().contains("stroke") {
        merged.insert("stroke", merge-stroke(inherited.stroke, own.stroke))
    }
    merged
}

/// Arguments for `fletcher.node` after applying all styles.
#let effective-node-args(node, graph-style) = {
    let inherited = (:)
    for (k, v) in graph-style {
        if is-node-style-key(k) {
            inherited.insert(k.slice("node-".len()), v)
        }
    }
    merge-args(inherited, node.args)
}

/// Arguments for `fletcher.edge` after applying all styles.
#let effective-edge-args(edge, graph-style) = {
    let inherited = (:)
    for (k, v) in graph-style {
        if k.starts-with("edge-") {
            inherited.insert(k.slice("edge-".len()), v)
        }
    }
    merge-args(inherited, edge.args)
}
