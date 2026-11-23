#import "./elements.typ": autograph-element, is-autograph-element, get-class
#import "dependencies.typ": testyfy

#let node(name, ..args) = {
    testyfy.type-one-of(name, (label, str))
    assert(args.pos().len() <= 1)
    let body = {
        let pos = args.pos()
        if pos.len() == 0 {
            str(name)
        } else {
            let body = pos.at(0)
            if body == none {
                body = box(width: 0.85em, height: 0.85em)
            }
            body
        }
    }
    autograph-element(
        "node",
        (
            name: name,
            body: body,
            args: args.named(),
        )
    )
}

#let is-autograph-node(e) = {
    (is-autograph-element(e) and get-class(e) == "node")
}
