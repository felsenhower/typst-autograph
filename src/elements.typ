#import "./dependencies.typ": testyfy

#let autograph-element(class, value) = {
    testyfy.typeof(class, str)
    testyfy.typeof(value, dictionary)
    let class = "autograph-" + class
    metadata((
        class: class,
        value: value,
    ))
}

#let is-autograph-element(e) = {
    if type(e) != content {
        return false
    }
    let fields = e.fields()
    let value = fields.at("value", default: none)
    if type(value) != dictionary {
        return false
    }
    let class = value.at("class", default: none)
    if type(class) != str {
        return false
    }
    class.starts-with("autograph-")
}

#let get-class(e) = {
    assert(is-autograph-element(e))
    e.value.class.replace("autograph-", "")
}

#let get-value(e) = {
    assert(is-autograph-element(e))
    e.value.value
}

#let extend-element(e, added-value) = {
    assert(is-autograph-element(e))
    testyfy.typeof(added-value, dictionary)
    let class = get-class(e)
    let old-value = get-value(e)
    let new-value = old-value + added-value
    autograph-element(class, new-value)
}

#let fixture-sample-elem() = {
    autograph-element("foo", ("bar": "baz"))
}

#let test-autograph-element() = {
    let received = fixture-sample-elem()
    let expected = metadata((
        class: "autograph-foo",
        value: (
            bar: "baz"
        )
    ))
    assert(received == expected)
}

#let test-is-autograph-element() = {
   assert(is-autograph-element(fixture-sample-elem()))
}

#let test-get-class() = {
    assert(get-class(fixture-sample-elem()) == "foo")
}

#let test-get-value() = {
    assert(get-value(fixture-sample-elem()) == ("bar": "baz"))
}

#let panic-on-autograph-element() = {
    autograph-element(42, ("foo": "bar"))
}

#let test-extend-element() = {
    let e = fixture-sample-elem()
    let more = (
        "monkey": "tree"
    )
    let received = extend-element(e, more)
    let expected = metadata((
        class: "autograph-foo",
        value: (
            bar: "baz",
            monkey: "tree"
        )
    ))
    assert(received == expected)
}
