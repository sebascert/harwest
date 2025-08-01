#!/usr/bin/env bash

# format sources

set -euo pipefail

root=".." # script/..
cd "$(dirname "${BASH_SOURCE[0]}")/$root" || exit 3

ruff format
ruff check --fix --select I
