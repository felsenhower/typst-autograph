#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "@local/autograph:0.1.3": diagram, node, edge
#diagram(
    graph-options: (
        edge-marks: none,
    ),
    node(<foo>),
    node(<bar>),
    node(<baz>),
    edge(<foo>, <bar>),
    edge(<foo>, <baz>),
    edge(<baz>, <bar>),
)
