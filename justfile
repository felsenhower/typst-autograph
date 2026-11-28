set default-list := true

VERSION := `grep -oP '(?<=version = ")[^"]+' typst.toml`

# Bump version to NEW_VERSION
bump-version NEW_VERSION:
    @echo Bumping from version {{VERSION}} to {{NEW_VERSION}}
    sed -i "$(/usr/bin/printf 's/version = "%s"/version = "%s"/g' "{{VERSION}}" "{{NEW_VERSION}}")" typst.toml
    sed -i "$(/usr/bin/printf 's/autograph:%1$s/autograph:%2$s/g; s+/tags/v%1$s/+/tags/v%2$s/+g; s+### Upcoming+### %2$s+g' "{{VERSION}}" "{{NEW_VERSION}}")" README.md
    find examples -iname '*.typ' -exec sed -i "$(/usr/bin/printf 's/autograph:%s/autograph:%s/g' "{{VERSION}}" "{{NEW_VERSION}}")" "{}" \;

install-local: package
    mkdir -p ~/.local/share/typst/packages/local/autograph/
    cp -r autograph ~/.local/share/typst/packages/local/autograph/{{VERSION}}

compile-manual:
    typst compile --root . docs/manual.typ docs/manual.pdf

compile-examples:
    cd examples && for f in *.typ ; do printf 'Compiling "%s"...\n' "$f" && typst compile --format svg "$f" ; done

build-deps:
    # Prerequisites:
    # - Install emscripten
    # - Add `source /etc/profile.d/emscripten.sh` to `.zshrc`
    # - cargo install wasi-stub
    # - cargo install --git https://github.com/Robotechnic/WebAssembly-protocol-generator.git
    make -C src/diagraph-layout wasm
    make -C src/diagraph-layout module

_package:
    mkdir autograph
    cp typst.toml autograph/
    cp lib.typ autograph/
    cp README.md autograph/
    cp -r examples autograph/
    cp -r logo autograph/
    mkdir autograph/src
    for f in src/*.typ ; do cp "$f" autograph/src/ ; done
    cp -r src/diagraph-layout/diagraph-layout autograph/src/

package: build-deps
    [ -d autograph ] && rm -r autograph || true
    just _package

test:
    tt run
    tinymist test lib.typ

package-check: package
    cd autograph && typst-package-check check

lint:
    tinymist lint lib.typ

check: test lint package-check
    @echo All done!
