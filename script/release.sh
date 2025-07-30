#!/usr/bin/env bash

# release a new version with tag and gh release
#
# requires gh cli

set -euo pipefail

root=".." # script/..
cd "$(dirname "${BASH_SOURCE[0]}")/$root" || exit 3

version_source="src/harwest/__init__.py"

bump_out=$(hatch version "$@" 2>&1 || true)
old_version=$(echo "$bump_out" | grep '^Old:' | awk '{print $2}' || true)
new_version=$(echo "$bump_out" | grep '^New:' | awk '{print $2}' || true)

if [ -z "$old_version" ] || [ -z "$new_version" ]; then
    echo "Invalid version bump"
    echo "Aborting"
    exit 1
fi

tag="v$new_version"

# hatch version --force "$old_version"
git restore "$version_source"

branch=$(git symbolic-ref --short HEAD)
if [ ! "$branch" = "main" ]; then
    echo "Not on main branch"
    echo "Aborting"
    exit 2
fi

if git rev-parse "refs/tags/$tag" >/dev/null 2>&1; then
    echo "Tag '$tag' exists locally"
    echo "Aborting"
    exit 2
fi

git fetch --tags >/dev/null 2>&1
if git ls-remote --tags origin | grep -q "refs/tags/$tag$"; then
    echo "Tag $tag exists on remote"
    echo "Aborting"
    exit 2
fi

if ! git diff --cached --quiet; then
    echo "Staged changes"
    git status --short
    echo "Aborting"
    exit 2
fi

if ! git diff --quiet; then
    echo "Uncommitted changes"
    git status --short
    read -rp "Do you want to continue? (y/N) " answer
    case "$answer" in
        [Yy]* ) ;;
        * )
            echo "Aborting"
            exit 2
            ;;
    esac
fi

hatch version "$@"

git add "$version_source"
git commit -m "Bump to version $new_version"
git push

git tag -a "$tag"
git push --tags

gh release create --draft --notes-from-tag "$tag"
