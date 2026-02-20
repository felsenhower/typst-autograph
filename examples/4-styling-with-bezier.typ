#import "template.typ": template
#show: template

#import "@local/autograph:0.1.0": diagram, node, edge
#import "@preview/fletcher:0.5.8": shapes
#let edge-style(color) = (
  stroke: 1pt + color,
  mark: (end: ">", fill: color, scale: 1.5)
)
#diagram(
  bezier: true,
  node-shape: shapes.rect,
  node-fill: red.lighten(75%),
  node-stroke: 1pt + red,
  node(<foo>, [Foo!]),
  node(<bar>, [Bar!]),
  node(<baz>, [Baz!], stroke: yellow, fill: yellow.lighten(75%)),
  edge(<foo>, <bar>, ..edge-style(blue)),
  edge(<foo>, <baz>, ..edge-style(blue)),
  edge(<baz>, <bar>, ..edge-style(green)),
)
