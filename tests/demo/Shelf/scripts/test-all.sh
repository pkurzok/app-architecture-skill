#!/usr/bin/env bash
# Runs every package's tests, picking the runner from the package's own platforms.
#
# A UI-free package declares macOS, so `swift test` runs it in seconds with no simulator. A
# package that renders is iOS-only and has to go through xcodebuild. Packages without a Tests/
# directory are skipped — features may ship untested, business modules may not, and the
# architecture gate is what enforces that.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# First available iPhone simulator, unless the caller named a destination.
simulator_destination() {
    if [ -n "${SIM_DESTINATION:-}" ]; then
        printf '%s' "$SIM_DESTINATION"
        return
    fi
    local name
    name="$(xcrun simctl list devices available | grep -o 'iPhone [^(]*' | head -1 | sed 's/ *$//')"
    if [ -z "$name" ]; then
        echo "no available iPhone simulator found" >&2
        return 1
    fi
    printf 'platform=iOS Simulator,name=%s' "$name"
}

# The scheme xcodebuild should run, read from the package directory we are already in:
# prefer the scheme named after the product, else take the first one offered.
scheme_for() {
    local product="$1" schemes first
    schemes="$(xcodebuild -list -json 2>/dev/null \
        | sed -n '/"schemes"/,/]/p' | grep -o '"[^"]*"' | grep -v '"schemes"' | tr -d '"')"
    if printf '%s\n' "$schemes" | grep -qx "$product"; then
        printf '%s' "$product"
        return
    fi
    first="$(printf '%s\n' "$schemes" | head -1)"
    printf '%s' "${first:-$product}"
}

status=0
for manifest in Packages/*/Package.swift; do
    pkg_dir="$(dirname "$manifest")"

    if [ ! -d "$pkg_dir/Tests" ]; then
        echo "== skip (no Tests/): $pkg_dir =="
        continue
    fi

    # Only a real platforms line counts — a commented-out one is documentation.
    if grep -v '^[[:space:]]*//' "$manifest" | grep -q '\.macOS('; then
        echo "== swift test: $pkg_dir =="
        if ! swift test --package-path "$pkg_dir"; then
            echo "FAILED: $pkg_dir" >&2
            status=1
            break
        fi
    else
        destination="$(simulator_destination)" || { status=1; break; }
        product="$(basename "$pkg_dir" | cut -d- -f2-)"
        echo "== xcodebuild test ($(printf '%s' "$destination" | sed 's/.*name=//')): $pkg_dir =="
        if ! (cd "$pkg_dir" && xcodebuild -quiet test \
                -scheme "$(scheme_for "$product")" \
                -destination "$destination" CODE_SIGNING_ALLOWED=NO); then
            echo "FAILED: $pkg_dir" >&2
            status=1
            break
        fi
    fi
done

exit $status
