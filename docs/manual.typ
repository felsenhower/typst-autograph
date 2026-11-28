#import "@preview/tidy:0.4.3"
#import "../lib.typ" as autograph
#import autograph: fletcher

#let TYPST_TOML = toml("/typst.toml")
#let VERSION = TYPST_TOML.package.version

#let logo = image("/logo/logo.svg", width: 60%)

#let package-summary = [
  A #link("https://typst.app/")[Typst] package for drawing graphs with
  automatic layout, built on top of
  #link("https://github.com/Jollywatt/typst-fletcher")[fletcher] and
  #link("https://graphviz.org/")[Graphviz].
]

#show footnote.entry: block.with(breakable: false)

/* Example blocks */

#let scope = (
  autograph: autograph,
  fletcher: fletcher,
  diagram: autograph.diagram,
  node: autograph.node,
  edge: autograph.edge,
  default-mark: autograph.default-mark,
)

#let example(code) = {
  assert((content, str).contains(type(code)))
  let code = {
    if type(code) == content {
      code.text
    } else {
      code
    }
  }
  let preview = {
    set text(font: "Libertinus Serif")
    eval(code, mode: "markup", scope: scope)
  }
  let code = raw(code, lang: "typ", block: true)
  let c = oklch(98%, 2%, 270deg)
  show: block.with(
    outset: 0.5em,
    radius: 0.5em,
    fill: gradient.linear(
      dir: ltr,
      (c, 0%),
      (c, 50%),
      (white, 80%),
      (white, 100%),
    ),
  )
  grid(
    columns: (1fr, auto),
    align: horizon,
    gutter: 1em,
    code, preview,
  )
}


/* Docstrings */

#let DOCSTRINGS = (
  ("../src/diagram.typ", "../src/node.typ", "../src/edge.typ")
    .map(path => tidy.parse-module(read(path), old-syntax: true).functions)
    .join()
    .map(fn => (fn.name, fn))
    .to-dict()
)


/* Crossrefs and linking */

// An invisible anchor that can be referenced with `@id`.
#let rich-ref(id, ..args) = [
  #metadata(args.named())
  #label(id)
]

#let show-ref(it) = {
  if it.element == none {
    panic("Unresolved reference:", it.target)
  } else if it.element.func() == metadata and "entity" in it.element.value {
    show: link.with(it.element.location())

    if it.supplement != auto {
      it.supplement
    } else {
      let (entity, ..info) = it.element.value
      if entity == "function" {
        raw(info.function + "()")
      } else if entity == "argument" {
        if state("current-function").get() == info.function {
          raw(info.argument)
        } else {
          raw(info.function + "." + info.argument)
        }
      } else {
        panic("unknown ref element", it.element)
      }
    }
  } else if it.element.func() == heading {
    let body = if it.supplement == auto { it.element.body } else { it.supplement }
    link(it.target, body)
  } else {
    panic("unsupported reference target", it.target)
  }
}


/* Function docstring styles */

#let show-type(ty) = {
  import tidy.styles.default: colors
  let clr = colors.at(ty, default: colors.default)
  h(2pt)
  box(outset: 2pt, fill: clr, radius: 2pt, raw(ty, lang: none))
  h(2pt)
}

#let show-function-signature(fn) = {
  show: par
  set text(font: "DejaVu Sans Mono", size: 0.8em)

  text("autograph.")
  text(fn.name, fill: tidy.styles.default.colors.signature-func-name)
  "(\n  "

  fn
    .args
    .pairs()
    .map(((arg-name, info)) => {
      if info.at("description", default: "") == "" {
        arg-name
      } else {
        link(label(fn.name + "-" + arg-name), arg-name)
      }
      if "types" in info and info.types != ("",) {
        ": " + info.types.map(show-type).join(" ")
      }
    })
    .join(",\n  ")

  ",\n)"
}

#let show-function-argument(fn, arg, info, level: 3) = {
  rich-ref(
    fn.name + "-" + arg,
    entity: "argument",
    function: fn.name,
    argument: arg,
  )

  block(width: 100%, sticky: true, {
    box(heading(raw(arg), level: level))
    if "types" in info {
      h(0.5em)
      info.types.map(show-type).join(text(0.8em)[ or ])
    }
    if "default" in info {
      text(0.8em)[ default ]
      raw(info.default, lang: "typc")
    }
    h(1fr)
    link(label(fn.name), text(gray, $arrow.tl$))
  })

  eval(info.description, mode: "markup", scope: scope)
  v(1em)
}

#let show-fn(name, level: 2) = {
  let fn = DOCSTRINGS.at(name)
  state("current-function").update(fn.name)

  rich-ref(fn.name, entity: "function", function: fn.name)
  heading(raw("autograph." + name + "()"), level: level)

  eval(fn.description, mode: "markup", scope: scope)
  show-function-signature(fn)

  for (arg, info) in fn.args {
    if info.at("description", default: "") == "" { continue }
    show-function-argument(fn, arg, info, level: level + 1)
  }
}


/* Show rules */

#let style(body) = {
  show ref: show-ref
  show raw.where(block: true): set text(1em)
  show raw.where(lang: "example"): example
  body
}


/* Document */

#set text(font: "Libertinus Serif")

// cover page

#v(1fr)

#align(center)[
  #logo

  #v(30pt)

  #package-summary

  #link(TYPST_TOML.package.repository.trim(".git", at: end))[
    `github.com/felsenhower/typst-autograph`
  ]

  *Version #VERSION*
]

#v(2cm, weak: true)

#[
  #outline(
    title: [Manual],
    target: selector(heading).after(<manual>, inclusive: false).before(<func-ref>, inclusive: false),
    depth: 3,
  )

  #outline(
    title: [Function Reference],
    target: selector(heading).after(<func-ref>, inclusive: false).before(<end>),
    depth: 2,
  )
]

#v(1fr)

#pagebreak()

#set document(title: "autograph manual", author: "Ruben Felgenhauer")
#set page(numbering: "1")
#set par(justify: true)

#show heading: it => {
  let size = (40pt, 25pt, 20pt, 15pt).at(it.level, default: 12pt)
  text(size, it)
}
#show heading.where(level: 1): it => {
  pagebreak(weak: true)
  align(center, text(weight: 200, smallcaps(it)))
  line(length: 100%)
}
#show link: it => underline(strong(it))
#show: style

= Manual <manual>

== Introduction <intro>

Import autograph with:
#raw(
  "#import \"@preview/autograph:" + VERSION + "\": diagram, node, edge",
  lang: "typ",
  block: true,
)

To draw a graph, use the @diagram function along with @node and @edge to define the nodes and edges of the graph.

```example
#diagram(
  node(<foo>),
  node(<bar>),
  node(<baz>),
  edge(<foo>, <bar>),
  edge(<foo>, <baz>),
  edge(<baz>, <bar>),
)
```

Autograph's syntax is somewhat of a hybrid between fletcher and the #link("https://graphviz.org/doc/info/lang.html")[dot language] of #link("https://graphviz.org/")[Graphviz].

#let diagraph-layout() = [
  #link("https://github.com/felsenhower/diagraph-layout")[diagraph-layout]#footnote[
    Since autograph v0.1.1, we are using a forked version of diagraph-layout that contains multiple fixes and extensions. I will switch back to the upstream diagraph-layout if the fixes get merged.
  ]
]

In fact, autograph uses Graphviz's layout engine (via #diagraph-layout()) to determine the node positions and edge paths, and #link("https://github.com/Jollywatt/typst-fletcher")[fletcher] is used to render the graph in Typst.

The `diagram` function is a wrapper around `fletcher.diagram` (which also works as a drop-in replacement) with some additional features to support the automatic layout.

For the sake of the comparison, here is the same graph rendered with #link("https://github.com/Robotechnic/diagraph")[diagraph], a more direct interface to Graphviz:

````example
#import "@preview/diagraph:0.3.6": *
#raw-render(
  ```dot
  digraph {
    foo -> bar
    foo -> baz
    baz -> bar
  }
  ```
)
````

We are not aiming for 100% parity with Graphviz; autograph focuses on providing a convenient interface for automatic graph layout within Typst. People who are familiar with both Graphviz and fletcher should feel right at home.

In the examples of this manual, `diagram`, `node`, and `edge` refer to the autograph functions unless stated otherwise.

//  draws graphs with automatic layout. Instead of telling every node where to go, you only say which nodes exist and how they are connected. 

// A @diagram contains @node[nodes] and @edge[edges]. Nodes are referred to by their name, which may be a string or a label. If a node has no body, its name is shown.

=== Nodes

The only required argument of @node is the name. It can be given as a `label` or a `str`.

By default, nodes simply display their name as the body. This can be changed by providing a `content` argument to @node. Passing `none` gives a small empty node.

```example
#diagram(
  node(<a>, $sum_(k=0)^n k$, shape: "rect"),
  node(<b>, text(red)[Some *text*], stroke: blue),
  node(<c>, none),
  edge(<a>, <b>),
  edge(<b>, <c>),
)
```

Additionally, autograph nodes can be styled exactly #link("https://fletcher-package.github.io/manual/nodes.html#node-styles")[like fletcher nodes]. See @styling for details.

=== Edges

Edges are used to connect two nodes. The first argument is the tail node and the second argument is the head node which can be given as a `label` or a `str`.

By default, edges are directed and point to the head node. Autograph doesn't explicitly support undirected edges. To draw them, simply disable the edge marks of the graph:

```example
#diagram(
  graph-options: (rankdir: ltr, edge-marks: none),
  node(<foo>),
  node(<bar>),
  node(<baz>),
  edge(<foo>, <bar>),
  edge(<foo>, <baz>),
  edge(<baz>, <bar>),
)
```

Bidirectional edges are similar: Simply add marks on both ends. We export the `default-mark` for your convenience.

```example
#diagram(
  graph-options: (
    rankdir: ltr,
    edge-marks: (default-mark, default-mark)
  ),
  node(<foo>),
  node(<bar>),
  node(<baz>),
  edge(<foo>, <bar>),
  edge(<foo>, <baz>),
  edge(<baz>, <bar>),
)
```

Edges can be styled using the same style arguments as fletcher edges. See @styling for details.

=== Graph options <graph-options>

Graph options can be separated into *layout options* and *styling options*. Layout options influence the positioning of nodes and edges, while styling options control their appearance.

For layout options, see the subsections below. They are not passed on to fletcher.

For styling options, see the @styling section below, more specifically the @graph-style subsection.

==== `engine`

The `engine` option selects the Graphviz layout engine. The available engines are `"dot"` (the default, for layered drawings of directed graphs), `"neato"` and `"fdp"` (spring models), `"sfdp"` (multiscale spring model for large graphs), `"circo"` (circular layout), `"twopi"` (radial layout), and `"osage"` (clustered layout). For more information, refer to #link("https://graphviz.org/docs/layouts/")[the Graphviz documentation].

```example
#diagram(
  graph-options: (engine: "circo"),
  node(<a>), node(<b>), node(<c>), node(<d>),
  edge(<a>, <b>), edge(<b>, <c>),
  edge(<c>, <d>), edge(<d>, <a>),
)
```

==== `rankdir` <rankdir>

The `rankdir` option selects the direction in which the graph is laid out when using the `"dot"` engine. It is one of `ttb` (the default), `btt`, `ltr`, and `rtl`.

```example
#diagram(
  graph-options: (rankdir: ltr),
  node(<a>), node(<b>), node(<c>),
  edge(<a>, <b>), edge(<a>, <c>),
)
```

== Styling <styling>

The look of nodes and edges is controlled with the same options as in fletcher. See the #link("https://fletcher-package.github.io/manual/intro.html#loc-3")[Fletcher documentation] for details. Styles can be given on three levels, from lowest to highest priority:

+ *Diagram arguments*: `node-*` and `edge-*` arguments of @diagram, e.g. `node-fill` or `edge-stroke`. These are also passed on to fletcher, so they apply to fletcher nodes and edges in the diagram as well. See @diagram-style.
+ *Graph options*: `node-*` and `edge-*` entries in the `graph-options` of @diagram. These only apply to autograph nodes and edges, not to fletcher elements. See @graph-style.
+ *Element arguments*: named arguments of @node and @edge, e.g. `fill` or `stroke`. See @element-styles.

Any style that is not set on any level falls back to the autograph default style, which draws nodes as ellipses with a black outline and edges as arrows.

=== Diagram-wide styles <diagram-style>

Exactly like the regular #link("https://fletcher-package.github.io/reference/main/diagram.html")[`fletcher.diagram`], you can pass arguments like `node-shape` which will then set the shape of all nodes inside the diagram.

This can be overridden by graph-wide styles (see @graph-style) and element-specific styles (see @element-styles).

```example
#diagram(
  node-shape: "rect",
  node-fill: red.lighten(75%),
  node-stroke: 1pt + red,
  edge-stroke: 1pt + blue,
  node(<foo>, [Foo!]),
  node(<bar>, [Bar!]),
  node(<baz>, [Baz!], stroke: yellow, fill: yellow.lighten(75%)),
  edge(<foo>, <bar>),
  edge(<foo>, <baz>),
  edge(<baz>, <bar>, stroke: green),
)
```

Here, the nodes `<foo>` and `<bar>` use the diagram-wide style, while `<baz>` overrides its fill and stroke. Likewise, the edge from `<baz>` to `<bar>` overrides the stroke.

=== Graph-wide styles <graph-style>

When a diagram mixes autograph and fletcher elements (see @mixing), you may want to style only the autograph elements. Put the styles into `graph-options` argument for this.

```example
#diagram(
  node-inset: 1em,
  node-fill: red.lighten(75%),
  node-stroke: 1pt + red,
  graph-options: (
    node-shape: "ellipse",
    node-fill: blue.lighten(75%),
  ),
  node(<foo>),
  node(
    <bar>,
    fill: green.lighten(75%),
  ),
  fletcher.node((30mm, 0mm), [Fletcher]),
  edge(<foo>, <bar>),
)
```

Here, the `node-stroke` setting in the diagram arguments applies to all nodes, fletcher or autograph. `node-fill` is overridden inside `graph-options` for all autograph nodes, but doesn't affect `<bar>` since it overrides it on an element level.

=== Element-specific styles <element-styles>

The @node and @edge functions support all style settings of their fletcher counterparts (see fletcher documentation: #link("https://fletcher-package.github.io/reference/main/node.html")[`node`], #link("https://fletcher-package.github.io/reference/main/edge.html")[`edge`]).

== Mixing with fletcher <mixing>

Since @diagram is a drop-in replacement for `fletcher.diagram`, you can freely place fletcher nodes and edges next to autograph elements. autograph re-exports the package version of fletcher that it was built with, so you can use this to make sure the versions are compatible. The same is true for CeTZ (`fletcher.cetz`).

#raw(
  "#import \"@preview/autograph:" + VERSION + "\" as autograph: diagram, fletcher",
  lang: "typ",
  block: true,
)

The order of all elements inside @diagram is preserved. We guarantee that the first autograph node inside the diagram (here: `<foo>`) will be at position `(0pt, 0pt)`. You can use these properties like shown in this example:

```example
#diagram(
    node-fill: blue.lighten(75%),
    node-inset: 2em,
    node-stroke: 1pt + blue,
    graph-options: (
      node-stroke: 1pt + black,
      node-fill: white,
    ),
    fletcher.node((-6em, 0mm), [Back]),
    autograph.node(<foo>, [Middle]),
    fletcher.node((6em, 0mm), [Front]),
    autograph.node(<bar>, [Order preserved!]),
    autograph.edge(<bar>, <foo>),
)
```

If you feel like this is too verbose and your example is a bit more compilcated, you might want to separate your autograph and fletcher elements by scope, like demonstrated in the following example. 

Fletcher elements can refer to autograph nodes by their names, so we can use `enclose: (<foo>, <bar>, <baz>)` to draw a box around the nodes.

```example
#diagram(
  graph-options: (engine: "circo"),
  node-fill: white,
  {
    import autograph: node, edge
    (
      node(<foo>),
      node(<bar>),
      node(<baz>),
      edge(<foo>, <bar>),
      edge(<foo>, <baz>),
      edge(<baz>, <bar>),
    )
  },
  {
    import fletcher: node, edge
    (
      node(
        enclose: (<foo>, <bar>, <baz>),
        shape: "rect",
        stroke: 1pt + blue,
        inset: 0.5em,
        fill: blue.lighten(75%),
        outset: 0.5em,
        name: <group>,
      ),
      node(
        (rel: (6.5em, 0em), to: <group.east>),
        stroke: none,
        fill: none,
        inset: 0mm,
        outset: 0.5em,
        text(red)[Look at this graph!],
        name: <nickelback>,
      ),
      edge(<nickelback>, <group>, "->", stroke: red),
    )
  },
)
```

#pagebreak()

== How it works

Internally, we use Graphviz's layout engine via #diagraph-layout(). To determine the layout, diagraph-layout requires the measurements of the nodes and the connections between the nodes, i.e. the edges.

The following steps are performed:

+ *Measure the nodes:* For this, a dummy `fletcher.diagram` with a single `fletcher.node` is created for each node and #link("https://typst.app/docs/reference/layout/measure/",`measure()`) is used to acquire the dimensions of the diagram. The diagram uses the same styling options and graph options as the final diagram, and the node styling arguments are applied as well. So options like `inset` which influence the layout, are taken into account when determining the node size.
+ *Determine the layout:* The nodes (including their sizes) and edges are passed to Graphviz. diagraph-layout gives us the layout which includes the positions of the nodes and the paths of the edges as Bézier curves#footnote[
  The paths are given as cubic #link("https://en.wikipedia.org/wiki/B%C3%A9zier_curve")[Bézier curves] which are represented as a list of points, where the length of the list upholds the property `len % 3 == 1` (so valid lengths would be 1, 4, 7, 10, ...). Traditionally, a single Bézier segment is defined by four points $p_0$, $p_1$, $p_2$, $p_3$: the starting point $p_0$, two control points $p_1$ and $p_2$, and the ending point $p_3$. Here, a Bézier curve like $((p_0, p_1, p_2, p_3), (p_3, p_4, p_5, p_6), ...)$ is represented as $(p_0, p_1, p_2, p_3, p_4, p_5, p_6, ...).$
].
+ *Shift the layout:* Since we guarantee that the first node is positioned at `(0pt, 0pt)`, we shift all nodes and edges accordingly.
+ *Draw the graph:* Nodes are drawn as `fletcher.node` and edges as `fletcher.edge`. All other elements are passed through unchanged. For the nodes, we use the previously computed positions.
For the edges, we use the new #link("https://fletcher-package.github.io/manual/edges.html#edge-kinds")[`custom`] edge kind in combination with #link("https://cetz-package.github.io/docs/api/draw-functions/shapes/bezier/")[`cetz.draw.bezier`].


= Function Reference <func-ref>

#show-fn("diagram")
#show-fn("node")
#show-fn("edge")

#metadata(none) <end>
