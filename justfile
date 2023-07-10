set shell := ["bash", "-uc"]
set windows-shell := ["cmd.exe", "/c"]

current := invocation_directory()
crystal := if os() == "windows" { trim(`where crystal`) } else { trim(`which crystal`) }

default:
    @just build

[unix]
all_spec output="{{current}}\\.build":
    -mkdir -p {{current}}/.build
    {{crystal}} build -o {{output}} spec/all_spec.cr --warnings all

[windows]
all_spec output="{{current}}/.build":
    -mkdir {{current}}\.build
    {{crystal}} build -o {{output}} spec\all_spec.cr --warnings all

[unix]
build output=".build/duktape":
    -mkdir -p {{current}}/.build
    {{crystal}} build -o {{output}} src/duktape.cr --warnings all

[windows]
build output=".build\\duktape":
    -mkdir {{current}}\.build
    {{crystal}} build -o {{output}} src\duktape.cr --warnings all

[unix]
clean:
    -rm -rf {{current}}/.build
    -rm -rf {{current}}/.crystal

[windows]
clean:
    -rmdir /q /s {{current}}\.build
    -rmdir /q /s {{current}}\.crystal

cleanlib:
    @just -f {{current}}/ext/justfile clean
    make -C {{current}}/ext -f Makefile.internal clean

libduktape:
    cd ext
    @just -f ext/justfile build

update:
    make -C {{current}}/ext -f Makefile.internal update-duktape
