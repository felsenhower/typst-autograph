#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "@local/autograph:0.1.3": diagram, node, edge
#diagram(
    graph-options: (engine: "neato"),
    edge-stroke: gray + 1pt,
    node(<a>),
    node(<b>),
    node(<c>),
    node(<d>),
    node(<e>),
    edge(<a>, <b>),
    edge(<b>, <c>),
    edge(<c>, <d>),
    edge(<d>, <e>),
    edge(<e>, <a>),
    edge(<b>, <e>),
)
