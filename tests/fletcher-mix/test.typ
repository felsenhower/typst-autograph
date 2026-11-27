#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "/lib.typ" as autograph: diagram, fletcher

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
        (rel: (2em, 0em), to: <foo.east>),
        stroke: 1pt + red.darken(50%),
        fill: red,
        shape: "chevron",
        angle: 45deg,
        inset: 1em,
        dir: left,
        [#text(fill: yellow, font: "DejaVu Sans Mono")[Wow!]]
    ),
    autograph.edge(<foo>, <bar>),
)
