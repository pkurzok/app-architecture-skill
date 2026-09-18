#!/usr/bin/env bash
# Self-test for the ArchitectureTests template: run the gate against every fixture tree and
# require the exact set of ARCH: lines the fixture expects.
#
# Deliberately no `set -e`: a fixture that *should* fail makes `swift test` exit non-zero, and
# the whole point is to keep going and report every case.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
template="$repo_root/skills/app-architecture/templates/ArchitectureTests"
fixtures="$repo_root/tests/gate/fixtures"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

# One build serves every fixture that keeps the template's own ArchitectureConfig; a fixture that
# overrides it gets its own build copy, because the config is compiled in.
build_for() {
    local case_dir="$1" name
    if [ -f "$case_dir/ArchitectureConfig.swift" ]; then
        name="$(basename "$case_dir")"
    else
        name="default"
    fi
    local copy="$work/$name"
    if [ ! -d "$copy" ]; then
        cp -R "$template" "$copy"
        if [ -f "$case_dir/ArchitectureConfig.swift" ]; then
            cp "$case_dir/ArchitectureConfig.swift" "$copy/Tests/ArchitectureTests/ArchitectureConfig.swift"
        fi
        swift build --package-path "$copy" --build-tests >/dev/null 2>&1
    fi
    printf '%s' "$copy"
}

status=0
passed=0
for case_dir in "$fixtures"/*/; do
    case_name="$(basename "$case_dir")"
    expected="$case_dir/expected.txt"
    copy="$(build_for "${case_dir%/}")"

    output="$(ARCHITECTURE_TESTS_ROOT="${case_dir%/}" swift test --package-path "$copy" 2>&1)"
    exit_code=$?
    printf '%s\n' "$output" | grep -o 'ARCH: .*' | sort -u > "$work/actual.txt"

    if ! diff -u "$expected" "$work/actual.txt" > "$work/diff.txt"; then
        echo "FAIL $case_name"
        sed 's/^/    /' "$work/diff.txt"
        status=1
        continue
    fi

    # A clean fixture must also leave the gate green, and a dirty one must turn it red.
    if [ -s "$expected" ] && [ "$exit_code" -eq 0 ]; then
        echo "FAIL $case_name"
        echo "    expected violations but swift test exited 0"
        status=1
        continue
    fi
    if [ ! -s "$expected" ] && [ "$exit_code" -ne 0 ]; then
        echo "FAIL $case_name"
        echo "    expected a clean run but swift test exited $exit_code"
        printf '%s\n' "$output" | sed 's/^/    /' | tail -20
        status=1
        continue
    fi

    echo "PASS $case_name"
    passed=$((passed + 1))
done

echo "$passed/$(ls -d "$fixtures"/*/ | wc -l | tr -d ' ') fixtures passed"
exit $status
