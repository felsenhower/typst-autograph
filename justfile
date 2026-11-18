set default-list := true

VERSION := `grep -oP '(?<=version = ")[^"]+' typst.toml`

# Bump version to NEW_VERSION
bump-version NEW_VERSION:
    @echo Bumping from version {{VERSION}} to {{NEW_VERSION}}
    sed -i "$(printf 's/version = "%s"/version = "%s"/g' "{{VERSION}}" "{{NEW_VERSION}}")" typst.toml
    sed -i "$(printf 's/autograph:%s/autograph:%s/g' "{{VERSION}}" "{{NEW_VERSION}}")" README.md

install-local: package
    mkdir -p ~/.local/share/typst/packages/local/autograph/
    cp -r autograph ~/.local/share/typst/packages/local/autograph/{{VERSION}}

compile-examples:
    cd examples && for f in [0-9]*.typ ; do typst compile --format svg "$f" ; done

package:
    [ -d autograph ] && rm -r autograph || true
    mkdir autograph
    cp lib.typ autograph/
    cp -r src autograph/
    cp typst.toml autograph/
