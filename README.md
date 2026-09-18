# app-architecture

An agent skill for iOS and macOS apps built out of Swift Package modules. It encodes one
pattern — `App → Feature → Business → Library`, every module a package, dependencies pointing
down — and ships the architecture tests that enforce it, so the rule is checked by `make verify`
rather than remembered in review.

```text
            may import →   App   fm-   bm-   lib- (plain)  lib- (UI)   UI framework
App shell                   –     ✓     ✓        ✓             ✓            ✓
fm-  Feature                ✗     ✗ ¹   ✓        ✓             ✓            ✓
bm-  Business               ✗     ✗     ✓        ✓             ✗            ✗ ²
lib- Library                ✗     ✗     ✗        ✓       ✓ → becomes UI   ✓ → becomes UI ²

¹ never a sibling feature — use a seam injected by the app shell
² unless the import carries `// ui-boundary: <reason>` AND the file is in the allowlist
```

The golden rule is the second-to-last column: **a business module renders nothing.** That is what
lets every business module declare macOS and run its tests under `swift test` in seconds, with no
simulator — and what keeps domain logic reusable when the UI is rewritten.

A **UI library is derived, not declared**: a `lib-` that imports a UI framework, or that imports
a UI library, is one. No fifth prefix, no list to maintain.

## What it installs into a project

| | |
|---|---|
| `Packages/ArchitectureTests/` | the gate: a Swift Testing package that discovers modules from the directory names and fails on upward imports, sibling-feature imports, UI in a business module, dishonest boundary markers, name collisions and untested business modules |
| `project.yml` + `Makefile` + `scripts/test-all.sh` | XcodeGen spec, the `make verify` gate, and a test runner that picks `swift test` or a simulator per package |
| `packages/{lib,bm,fm}-Package.swift` | one manifest template per layer |
| `.swiftlint.yml`, `.gitignore`, `AGENTS.md` | zero-warning lint, a gitignored generated project, and a six-line note so the next agent finds the pattern |

Violations come out as single, greppable lines:

```text
ARCH: Catalog imports UIKit — UI framework in business module (Packages/bm-Catalog/Sources/Catalog/CoverImage.swift:3)
ARCH: Feature BookList imports sibling feature Settings (Packages/fm-BookList/Sources/BookList/BookListView.swift:5)
ARCH: Packages/lib-Formatting/Package.swift declares ../bm-Catalog — upward dependency
```

## Install

```sh
npx skills add pkurzok/app-architecture-skill
```

Or clone and symlink it yourself:

```sh
git clone https://github.com/pkurzok/app-architecture-skill ~/ws/app-architecture-skill
ln -sfn ~/ws/app-architecture-skill/skills/app-architecture ~/.agents/skills/app-architecture
ln -sfn ../../.agents/skills/app-architecture ~/.claude/skills/app-architecture
```

Skills are picked up at session start, so restart your agent afterwards.

## Tests

The skill is tested, not asserted. Three layers:

```sh
bash tests/check-skill.sh                 # frontmatter, word budget, scrub
bash tests/gate/run.sh                    # the gate against 20 fixture trees, exact expected output
make -C tests/demo/Shelf verify           # a real iOS app built only from the templates
```

And the part that matters most: five scenarios run past subagents twice, once without the skill
and once with it. `tests/records/baseline.md` is what a competent agent does unaided;
`tests/records/expected.md` is what the skill must add. The headline from the baseline is worth
knowing before you edit anything:

> No baseline run broke a rule. Not one upward import, not one sibling-feature import, not one UI
> framework in a business module, across eleven runs. Every failure was a convention failure —
> the shape of the answer, not its legality.

So the skill's value is concentrated in three places: the **seam** (a declared `Equatable` type
with a stable `id` in a UI library, injected by the app shell), the **project skeleton** that
makes the pattern outlive its author, and the **derived-UI-library rule**. Read
`tests/records/expected.md` before changing the wording; a row that stops firing is a regression.

## Credit

This is **strongly inspired by** the [JET iOS modular architecture](https://albertodebortoli.com/2026/07/15/revisiting-the-jet-ios-modular-architecture-in-2026/)
by Alberto De Bortoli — it is not that architecture, and nothing here is endorsed by or
affiliated with JET. Read the original: it is the better explanation of why the layers exist.

Where this one diverges: it adds a **Business** layer between Feature and Library, and it drops
demo apps, Tuist, and the separate SDK/Utility categories. Those choices are mine, and so is
anything that turns out to be wrong about them.

## Licence

MIT — see [LICENSE](LICENSE).
