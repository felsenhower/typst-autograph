#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "/lib.typ" as autograph: diagram, node, edge, fletcher

// Precedence: node args > graph-options > diagram args.
#diagram(
    node-fill: red.lighten(75%),
    node-stroke: 1pt + red,
    graph-options: (node-shape: "rect", node-stroke: 1pt + blue),
    node(<foo>),
    node(<bar>, stroke: green),
    fletcher.node((30mm, 0mm), [Fletcher]),
    edge(<foo>, <bar>),
)
