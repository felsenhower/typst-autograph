#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "/lib.typ" as autograph: diagram, node, edge

#diagram(
  node(<foo>, []),
  node(<bar>, []),
  node(<baz>, []),
  edge(<foo>, <bar>),
  edge(<foo>, <baz>),
  edge(<baz>, <bar>),
)
