#import "template.typ": template
#show: template

#import "@local/autograph:0.1.3": diagram, node, edge
#diagram(
  node(<foo>),
  node(<bar>),
  node(<baz>),
  edge(<foo>, <bar>),
  edge(<foo>, <baz>),
  edge(<baz>, <bar>),
)
