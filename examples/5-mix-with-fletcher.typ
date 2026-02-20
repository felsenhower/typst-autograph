#import "template.typ": template
#show: template

#import "@local/autograph:0.1.0" as autograph: diagram
#import "@preview/fletcher:0.5.8" as fletcher: shapes
#diagram(
  engine: "neato",
  autograph.node(<foo>),
  autograph.node(<bar>),
  autograph.node(<baz>),
  autograph.edge(<foo>, <bar>),
  autograph.edge(<foo>, <baz>),
  autograph.edge(<baz>, <bar>),
  fletcher.node(
    enclose: (<foo>, <bar>, <baz>),
    shape: shapes.brace.with(
      dir: right,
      length: 100% - 3em,
      sep: 10pt,
      label: [Look at this graph!]
    )
  ),
)
