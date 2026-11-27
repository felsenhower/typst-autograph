#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "/lib.typ" as autograph: diagram, fletcher

#diagram(
    node-fill: white,
    node-inset: 2em,
    fletcher.node((-25mm, 0mm), [Back], fill: yellow, stroke: orange),
    autograph.node(<foo>, [Middle]),
    fletcher.node((25mm, 0mm), [Front], fill: yellow, stroke: orange),
    autograph.node(<bar>, [Order preserved!]),
    autograph.edge(<bar>, <foo>),
)
