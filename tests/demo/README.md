# `Shelf` — the demo project

A small iOS app built from nothing but `skills/app-architecture/templates/`. It exists to prove
two things: that the templates produce a project that generates, tests, lints and builds, and
that the architecture gate passes on a project that follows the pattern.

It is also the fixture the scenario runs in `tests/records/` start from.

## What is in it

| Module | Layer | Why |
|---|---|---|
| `lib-Core` | Library | `BookID`, a date-to-year helper. Domain-agnostic, tested. |
| `lib-DesignSystem` | Library (UI) | `Spacing`, `cardStyle()`. Renders, so it is iOS-only and untested. |
| `bm-Catalog` | Business | `Book`, `CatalogStore`, `CatalogSettings`, sorting. Tested. |
| `bm-Analytics` | Business | `Analytics.track(event:)` and an in-memory sink. Tested. |
| `fm-BookList` | Feature | The shelf screen and its view model. One view-model test. |
| `fm-Settings` | Feature | The sort-order picker. No test target. |
| `App/Sources` | App | The composition root: builds the stores, shows the shelf. |

Two omissions are deliberate, not oversights:

- **no screen tracking and no way to open Settings from the shelf.** The scenario runs ask an
  agent to add exactly those, so the demo has to start without them.
- **no `AGENTS.md`.** The baseline has to be a project that *follows* the pattern without
  *explaining* it, otherwise a run without the skill is not a fair baseline.

## How it was generated

Every file below came from a template. This is the sequence, and it is the same one SKILL.md
gives as "start a new project".

```sh
SKILL=~/.claude/skills/app-architecture
APP=Shelf

mkdir -p "$APP"/App/Sources "$APP"/Packages "$APP"/scripts
cd "$APP"

cp "$SKILL/templates/project.yml"          project.yml
cp "$SKILL/templates/Makefile"             Makefile
cp "$SKILL/templates/scripts/test-all.sh"  scripts/test-all.sh
cp "$SKILL/templates/swiftlint.yml"        .swiftlint.yml
cp "$SKILL/templates/gitignore"            .gitignore
cp "$SKILL/templates/AGENTS.md"            AGENTS.md      # skipped for this demo, see above
cp -R "$SKILL/templates/ArchitectureTests" Packages/ArchitectureTests

sed -i '' "s/__APP__/$APP/g; s/__BUNDLE_PREFIX__/com.example/g" project.yml Makefile
sed -i '' "s/appName = \"App\"/appName = \"$APP\"/" \
    Packages/ArchitectureTests/Tests/ArchitectureTests/ArchitectureConfig.swift
```

Then once per module — prefix `lib`/`bm`/`fm`, module name without the prefix:

```sh
mkdir -p Packages/bm-Catalog/Sources/Catalog Packages/bm-Catalog/Tests/CatalogTests
cp "$SKILL/templates/packages/bm-Package.swift" Packages/bm-Catalog/Package.swift
sed -i '' "s/__NAME__/Catalog/g" Packages/bm-Catalog/Package.swift
```

What is left to do by hand in each file is the same short list every time: uncomment and fill
the module's real dependencies in its `Package.swift`, add the module to `packages:` and, if the
shell uses it, to the app target's `dependencies:` in `project.yml`, and write the sources.

Finally:

```sh
make generate && make verify && make build-app
```

## Working with it

The demo is a **fixture**. Nothing edits it in place — a scenario run copies it first:

```sh
rsync -a --exclude .build --exclude .swiftpm --exclude '*.xcodeproj' --exclude DerivedData \
    tests/demo/Shelf/ "$SOMEWHERE/run/"
```

`Shelf.sha256` is the manifest of the pristine tree. Regenerating it and finding a difference
means a run wrote into the fixture instead of into its copy:

```sh
(cd tests/demo/Shelf && find . -type f -not -path '*/.build/*' -not -path '*/.swiftpm/*' \
    -not -path '*.xcodeproj/*' -not -path './DerivedData/*' | sort | xargs shasum -a 256)
```
