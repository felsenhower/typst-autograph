#import "./elements.typ": autograph-element, is-autograph-element, get-class
#import "dependencies.typ": testyfy

#let edge(tail, head, ..args) = {
    testyfy.type-one-of(tail, (label, str))
    testyfy.type-one-of(head, (label, str))
    assert(args.pos().len() == 0)
    autograph-element(
        "edge",
        (
            tail: tail,
            head: head,
            args: args.named(),
        )
    )
}

#let is-autograph-edge(e) = {
    (is-autograph-element(e) and get-class(e) == "edge")
}
