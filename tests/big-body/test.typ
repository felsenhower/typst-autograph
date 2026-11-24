#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "/lib.typ" as autograph: diagram, node, edge

#diagram(
  node(<foo>, lorem(2)),
  node(<bar>, lorem(2)),
  node(<baz>, box(width: 6cm, lorem(40))),
  edge(<foo>, <bar>),
  edge(<foo>, <baz>),
  edge(<baz>, <bar>),
)
