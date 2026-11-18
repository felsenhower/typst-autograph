set default-list := true

VERSION := `grep -oP '(?<=version = ")[^"]+' typst.toml`

# Bump version to NEW_VERSION
bump-version NEW_VERSION:
    @echo Bumping from version {{VERSION}} to {{NEW_VERSION}}
    sed -i "$(printf 's/version = "%s"/version = "%s"/g' "{{VERSION}}" "{{NEW_VERSION}}")" typst.toml
    sed -i "$(printf 's/autograph:%s/autograph:%s/g' "{{VERSION}}" "{{NEW_VERSION}}")" README.md

install-local:
    mkdir -p ~/.local/share/typst/packages/local/autograph/{{VERSION}}
    cp lib.typ ~/.local/share/typst/packages/local/autograph/{{VERSION}}/
    cp -r src ~/.local/share/typst/packages/local/autograph/{{VERSION}}/
    cp typst.toml ~/.local/share/typst/packages/local/autograph/{{VERSION}}/

compile-examples:
    cd examples && for f in [0-9]*.typ ; do typst compile --format svg "$f" ; done
