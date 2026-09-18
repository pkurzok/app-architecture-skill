#!/usr/bin/env bash
# Judge a scenario run with a *pristine* copy of the gate: `gate-run.sh <run-dir> <app-name>`.
#
# Deliberately not the run's own Packages/ArchitectureTests — an agent may have edited that, and
# the point is to score the run against the rules as written, including its allowlist being empty.
# Prints the ARCH: lines, sorted and unique, and nothing else.
set -uo pipefail

run_dir="${1:?usage: gate-run.sh <run-dir> <app-name>}"
app_name="${2:?usage: gate-run.sh <run-dir> <app-name>}"
template="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/../skills/app-architecture/templates/ArchitectureTests"
template="$(cd "$(dirname "$template")" && pwd)/$(basename "$template")"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "$template" "$work/gate"
sed -i '' "s/appName = \"App\"/appName = \"$app_name\"/" \
    "$work/gate/Tests/ArchitectureTests/ArchitectureConfig.swift"

ARCHITECTURE_TESTS_ROOT="$(cd "$run_dir" && pwd)" \
    swift test --package-path "$work/gate" 2>&1 | grep -o 'ARCH: .*' | sort -u
