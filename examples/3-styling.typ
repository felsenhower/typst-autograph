#import "template.typ": template
#show: template

#import "@local/autograph:0.1.3": diagram, node, edge
#diagram(
  node-shape: "rect",
  node-fill: red.lighten(75%),
  node-stroke: 1pt + red,
  edge-stroke: 1pt + blue,
  edge-corner-radius: 75pt,
  node(<foo>, [Foo!]),
  node(<bar>, [Bar!]),
  node(<baz>, [Baz!], stroke: yellow, fill: yellow.lighten(75%)),
  edge(<foo>, <bar>),
  edge(<foo>, <baz>),
  edge(<baz>, <bar>, stroke: green),
)
