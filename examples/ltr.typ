#set page(
    width: auto,
    height: auto,
    margin: 1em,
    fill: white,
)

#import "@local/autograph:0.2.0": diagram, node, edge
#diagram(
    graph-options: (rankdir: ltr),
    node-shape: "rect",
    node-corner-radius: 3pt,
    node(<src>, [Source]),
    node(<lex>, [Lexer]),
    node(<parse>, [Parser]),
    node(<check>, [Checker]),
    node(<gen>, [Codegen]),
    node(<out>, [Output]),
    edge(<src>, <lex>),
    edge(<lex>, <parse>),
    edge(<parse>, <check>),
    edge(<parse>, <gen>),
    edge(<check>, <gen>),
    edge(<gen>, <out>),
)
