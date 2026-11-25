#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "/lib.typ" as autograph: diagram, node, edge

#diagram(
    graph-options: (engine: "twopi",),
    node(<a>),
    node(<b>),
    node(<c>),
    node(<d>),
    node(<e>),
    edge(<a>, <b>),
    edge(<a>, <c>),
    edge(<a>, <d>),
    edge(<a>, <e>),
)
