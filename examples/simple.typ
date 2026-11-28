#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "@local/autograph:0.2.0": diagram, node, edge
#diagram(
    node(<foo>),
    node(<bar>),
    node(<baz>),
    edge(<foo>, <bar>),
    edge(<foo>, <baz>),
    edge(<baz>, <bar>),
)
