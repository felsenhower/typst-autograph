#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "/lib.typ" as autograph: diagram, fletcher

// This test is currently slightly broken because of a fletcher bug.
// It will likely be fixed with fletcher v0.6.1.

#diagram(
    node-fill: white,
    autograph.node(<foo>),
    autograph.node(<bar>),
    fletcher.node(
        enclose: (<foo>, <bar>),
        stroke: 1pt + blue,
        fill: blue.lighten(50%),
        shape: "rect",
    ),
    fletcher.node(
        (rel: (45deg, 10mm), to: <foo>),
        stroke: 1pt + red.darken(50%),
        fill: red,
        width: 10mm,
        height: 10mm,
        shape: "chevron",
    ),
    autograph.edge(<foo>, <bar>),
)
