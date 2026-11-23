#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "/lib.typ" as autograph: diagram, node, edge

#diagram(
    engine: "fdp",
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
    edge(<b>, <e>)
)
