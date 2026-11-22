set default-list := true

VERSION := `grep -oP '(?<=version = ")[^"]+' typst.toml`

# Bump version to NEW_VERSION
bump-version NEW_VERSION:
    @echo Bumping from version {{VERSION}} to {{NEW_VERSION}}
    sed -i "$(printf 's/version = "%s"/version = "%s"/g' "{{VERSION}}" "{{NEW_VERSION}}")" typst.toml
    sed -i "$(printf 's/autograph:%s/autograph:%s/g' "{{VERSION}}" "{{NEW_VERSION}}")" README.md
    find examples -iname '*.typ' -exec sed -i "$(printf 's/autograph:%s/autograph:%s/g' "{{VERSION}}" "{{NEW_VERSION}}")" "{}" \;

install-local: package
    mkdir -p ~/.local/share/typst/packages/local/autograph/
    cp -r autograph ~/.local/share/typst/packages/local/autograph/{{VERSION}}

compile-examples:
    cd examples && for f in [0-9]*.typ ; do printf 'Compiling "%s"...\n' "$f" && typst compile --format svg "$f" ; done

build-deps:
    # Prerequisites:
    # - Install emscripten
    # - Add `source /etc/profile.d/emscripten.sh` to `.zshrc`
    # - cargo install wasi-stub
    # - cargo install --git https://github.com/Robotechnic/WebAssembly-protocol-generator.git
    git submodule update --init
    make -C src/diagraph-layout wasm
    make -C src/diagraph-layout module

package: build-deps
    [ -d autograph ] && rm -r autograph || true
    mkdir autograph
    cp typst.toml autograph/
    cp lib.typ autograph/
    cp README.md autograph/
    cp -r examples autograph/
    cp -r logo autograph/
    mkdir autograph/src
    cp src/impl.typ autograph/src/
    cp -r src/diagraph-layout/diagraph-layout autograph/src/
