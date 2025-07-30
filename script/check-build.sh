#!/usr/bin/env bash

# check for files in sdist

set -euo pipefail

debug=0

while (( $# )); do
    case "$1" in
        -d|--debug)
            debug=1
            shift
            ;;
        *)
            echo "unexpected $1"
            exit 2
            ;;
    esac
done

root=".." # script/..
cd "$(dirname "${BASH_SOURCE[0]}")/$root" || exit 3

version=$(hatch version)

archive="dist/harwest2-$version.tar.gz"
sdist="${archive%.tar.gz}"

uv build 2> /dev/null

if [ -d "$sdist" ]; then
    rm -r "$sdist"
fi

mkdir -p "$sdist"
tar -xzf "$archive" -C "$sdist" --strip-components=1

ignored_vcs=".github|script"
ignored_build="PKG-INFO"

# expect all vcs files tracked, excluding $ignored_vcs and removing the
# trailing src/
mapfile -t expected \
    < <(git ls-files | grep -Ev "$ignored_vcs" | sed 's|^src/||' | sort)

mapfile -t actual \
    < <(cd "$sdist" && find . -type f | grep -Ev "$ignored_build" | sed 's|^\./||' | sort)

missing=$(comm -23 <(printf '%s\n' "${expected[@]}") <(printf '%s\n' "${actual[@]}"))
extra=$(comm -13 <(printf '%s\n' "${expected[@]}") <(printf '%s\n' "${actual[@]}"))


if [ "$debug" -eq 1 ]; then
    echo "    Expected:"
    printf '%s\n' "${expected[@]}"
    echo "    Actual:"
    printf '%s\n' "${actual[@]}"
    echo
fi

echo "    Missing:"
echo "$missing"
echo
echo "    Extra:"
echo "$extra"

if [ -n "$missing" ] || [ -n "$extra" ]; then
    exit 1
fi
