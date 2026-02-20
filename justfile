default:
	@just --list

VERSION := `grep -oP '(?<=version = ")[^"]+' typst.toml`

install-local:
    mkdir -p ~/.local/share/typst/packages/local/autograph/{{VERSION}}
    cp lib.typ ~/.local/share/typst/packages/local/autograph/{{VERSION}}/
    cp -r src ~/.local/share/typst/packages/local/autograph/{{VERSION}}/
    cp typst.toml ~/.local/share/typst/packages/local/autograph/{{VERSION}}/

compile-examples:
    cd examples && for f in [0-9]*.typ ; do typst compile --format svg "$f" ; done
