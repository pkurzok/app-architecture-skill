#!/usr/bin/env bash
# Static checks on the skill itself: frontmatter, word budget, the two prescriptions it must
# never soften, leftover placeholders, and a scrub for anything private.
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skill_dir="$repo_root/skills/app-architecture"
skill="$skill_dir/SKILL.md"
status=0

fail() { echo "FAIL: $*"; status=1; }
pass() { echo "ok: $*"; }

# --- the file exists ------------------------------------------------------
if [ ! -f "$skill" ]; then
    echo "FAIL: no $skill"
    exit 1
fi

# --- frontmatter ----------------------------------------------------------
frontmatter="$(awk 'NR==1 && $0=="---" {inside=1; next} inside && $0=="---" {exit} inside' "$skill")"
if [ -z "$frontmatter" ]; then
    fail "SKILL.md has no YAML frontmatter"
else
    name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name: *//p')"
    description="$(printf '%s\n' "$frontmatter" | sed -n 's/^description: *//p')"

    if [ "$name" = "$(basename "$skill_dir")" ]; then
        pass "name matches the directory ($name)"
    else
        fail "name '$name' does not match the directory '$(basename "$skill_dir")'"
    fi

    if printf '%s' "$name" | grep -qE '^[A-Za-z0-9-]+$'; then
        pass "name uses only letters, numbers and hyphens"
    else
        fail "name '$name' has characters other than letters, numbers and hyphens"
    fi

    case "$description" in
        "Use when"*) pass "description starts with \"Use when\"" ;;
        *) fail "description must start with \"Use when\"" ;;
    esac

    chars="$(printf '%s' "$frontmatter" | wc -c | tr -d ' ')"
    if [ "$chars" -le 1024 ]; then
        pass "frontmatter is $chars characters (limit 1024)"
    else
        fail "frontmatter is $chars characters, over the 1024 limit"
    fi
fi

# --- word budget ----------------------------------------------------------
words="$(wc -w < "$skill" | tr -d ' ')"
if [ "$words" -le 900 ]; then
    pass "SKILL.md is $words words (budget 900)"
else
    fail "SKILL.md is $words words, over the 900 budget"
fi

# --- the two things the skill must never soften ---------------------------
# Every mention of Tuist or a demo app has to be a prohibition.
soft="$(grep -niE 'tuist|demo app' "$skill" | grep -viE 'no |never' || true)"
if [ -z "$soft" ]; then
    pass "every mention of Tuist / demo apps is a prohibition"
else
    fail "these lines mention Tuist or a demo app without forbidding it:"
    printf '%s\n' "$soft" | sed 's/^/    /'
fi

# --- no unreplaced placeholders outside templates/ ------------------------
# A `sed` line that substitutes a placeholder is the instruction for replacing it, not a
# leftover — the workflows and the demo README both have to spell those commands out.
leftover="$(grep -rn '__[A-Z_]*__' "$repo_root" \
    --exclude-dir=.git --exclude-dir=.build --exclude-dir=.swiftpm \
    --exclude-dir=templates --exclude-dir=DerivedData --exclude=check-skill.sh 2>/dev/null \
    | grep -v '\.xcodeproj/' | grep -v 'sed ' || true)"
if [ -z "$leftover" ]; then
    pass "no unreplaced __PLACEHOLDER__ outside templates/"
else
    fail "unreplaced placeholders:"
    printf '%s\n' "$leftover" | sed 's/^/    /'
fi

# --- scrub ----------------------------------------------------------------
private="$(grep -rniE 'pnab|h(oe|ö)rspieler|photo.?memo|playtales|99ED34GJ9X|peterkurzok\.|/Users/|claude-501|ws-privat|ws-workshop' \
    "$repo_root" --exclude-dir=.git --exclude-dir=.build --exclude-dir=.swiftpm \
    --exclude-dir=DerivedData --exclude=check-skill.sh 2>/dev/null \
    | grep -v '\.xcodeproj/' || true)"
if [ -z "$private" ]; then
    pass "no private identifiers, user paths or signing data"
else
    fail "private data found:"
    printf '%s\n' "$private" | sed 's/^/    /' | head -20
fi

exit $status
