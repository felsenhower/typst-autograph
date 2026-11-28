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
    edge(<foo>, <bar>, stroke: red),
    edge(<foo>, <bar>, stroke: orange),
    edge(<foo>, <bar>, stroke: yellow),
    edge(<bar>, <foo>, stroke: green),
    edge(<bar>, <foo>, stroke: blue),
    edge(<bar>, <foo>, stroke: purple),
)
