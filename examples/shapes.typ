#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "@local/autograph:0.2.0": diagram, node, edge
#diagram(
    node(<circle>, [Circle], shape: "circle", fill: red.lighten(80%), stroke: red),
    node(<rect>, [Rect], shape: "rect", fill: green.lighten(80%), stroke: green),
    node(<diamond>, [Diamond], shape: "diamond", fill: blue.lighten(80%), stroke: blue),
    node(<pill>, [Pill], shape: "pill", fill: orange.lighten(80%), stroke: orange),
    node(<hex>, [Hexagon], shape: "hexagon", fill: purple.lighten(80%), stroke: purple),
    edge(<circle>, <rect>),
    edge(<circle>, <diamond>),
    edge(<rect>, <pill>),
    edge(<diamond>, <pill>),
    edge(<diamond>, <hex>),
)
