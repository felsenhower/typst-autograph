#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "@local/autograph:0.1.3" as autograph: diagram, node, edge
#diagram(
    graph-options: (rankdir: ltr),
    edge-stroke: 1pt + blue,
    node(<a>, $A$),
    node(<b>, $B$),
    node(<c>, $C$),
    node(<d>, $D$),
    edge(<a>, <b>, marks: (autograph.default-mark, autograph.default-mark)),
    edge(<b>, <c>, marks: (none, "stealth")),
    edge(<c>, <d>, marks: ("stealth", "stealth"), stroke: red),
    edge(<a>, <d>, marks: (none, none), stroke: (paint: gray, dash: "dashed")),
)
