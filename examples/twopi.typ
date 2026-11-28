#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "@local/autograph:0.1.3": diagram, node, edge
#diagram(
    graph-options: (engine: "twopi"),
    node-fill: blue.lighten(85%),
    node-stroke: 1pt + blue,
    edge-marks: none,
    node(<hub>, [Hub], fill: orange.lighten(70%), stroke: 1pt + orange),
    node(<a>),
    node(<b>),
    node(<c>),
    node(<d>),
    node(<e>),
    node(<f>),
    edge(<hub>, <a>),
    edge(<hub>, <b>),
    edge(<hub>, <c>),
    edge(<hub>, <d>),
    edge(<hub>, <e>),
    edge(<hub>, <f>),
    edge(<a>, <b>),
    edge(<d>, <e>),
)
