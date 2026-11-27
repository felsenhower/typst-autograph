#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "/lib.typ" as autograph: diagram, node, edge, default-mark

#diagram(
  graph-options: (
    edge-marks: none,
  ),
  node(<foo>),
  node(<bar>),
  node(<baz>),
  edge(<foo>, <bar>, marks: (default-mark, default-mark)),
  edge(<foo>, <baz>, marks: (default-mark, none)),
  edge(<baz>, <bar>, marks: (none, default-mark)),
)
