#import "./dependencies.typ": testyfy

#let is-point(p) = {
    if type(p) != dictionary {
        return false
    }
    if p.keys().sorted() != ("x", "y") {
        return false
    }
    if type(p.x) != length {
        return false
    }
    if type(p.y) != length {
        return false
    }
    true
}

#let point-to-array(p) = {
    assert(is-point(p))
    (p.x, p.y)
}

#let test-is-point() = {
    assert(is-point((x: 1pt, y: 2pt)))
    assert(not is-point((x: 1, y: 2)))
    assert(not is-point((x: "foo", y: "bar")))
    assert(not is-point((x: 1pt, y: 2pt, z: 3pt)))
    assert(not is-point((1pt, 2pt)))
}

#let subtract-points(p1, p2) = {
    assert(is-point(p1))
    assert(is-point(p2))
    (
        x: p1.x - p2.x,
        y: p1.y - p2.y,
    )
}

#let test-subtract-points() = {
    let a = (x: 10pt, y: 20pt)
    let b = (x: 1pt, y: 2pt)
    let expected = (x: 9pt, y: 18pt)
    let received = subtract-points(a, b)
    assert(expected == received)
}
