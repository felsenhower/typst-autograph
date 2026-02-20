#import "template.typ": template
#show: template

#import "@local/autograph:0.1.0": diagram, node, edge
#diagram(
  bezier: true,
  node(<foo>),
  node(<bar>),
  node(<baz>),
  edge(<foo>, <bar>),
  edge(<foo>, <baz>),
  edge(<baz>, <bar>),
)
