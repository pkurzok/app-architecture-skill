# Workflows

`$SKILL` below is this skill's directory — `~/.claude/skills/app-architecture` on Claude Code,
`~/.agents/skills/app-architecture` elsewhere. Every recipe ends with `make verify`.

## 1. Start a project

The skeleton is not optional. A project missing any of these keeps the pattern only in the head
of whoever built it: nothing carries it to the next module, and nothing notices when it breaks.

```sh
APP=Shelf                     # the app and scheme name
PREFIX=com.example            # your bundle id prefix

mkdir -p "$APP"/App/Sources "$APP"/Packages "$APP"/scripts
cd "$APP"

cp "$SKILL/templates/project.yml"          project.yml
cp "$SKILL/templates/Makefile"             Makefile
cp "$SKILL/templates/scripts/test-all.sh"  scripts/test-all.sh
cp "$SKILL/templates/swiftlint.yml"        .swiftlint.yml     # note the rename
cp "$SKILL/templates/gitignore"            .gitignore         # and this one
cp "$SKILL/templates/AGENTS.md"            AGENTS.md
cp -R "$SKILL/templates/ArchitectureTests" Packages/ArchitectureTests

sed -i '' "s/__APP__/$APP/g; s/__BUNDLE_PREFIX__/$PREFIX/g" project.yml Makefile
sed -i '' "s/appName = \"App\"/appName = \"$APP\"/" \
    Packages/ArchitectureTests/Tests/ArchitectureTests/ArchitectureConfig.swift
```

Then add modules (recipe 2), write `App/Sources/<App>App.swift` as the composition root, and:

```sh
make generate && make verify && make build-app
```

**For a macOS app**, three values change: `platform` on the target in `project.yml`, the
`deploymentTarget` above it, and the destination `make build-app` passes to `xcodebuild`.

Checklist — all of these exist when you are done:

- [ ] `project.yml`, committed; `.xcodeproj` generated and gitignored
- [ ] `Makefile` and `scripts/test-all.sh`
- [ ] `.swiftlint.yml` and `.gitignore`
- [ ] `Packages/ArchitectureTests` with `appName` set
- [ ] `AGENTS.md`
- [ ] every package directory named `lib-`, `bm-` or `fm-`
- [ ] no Tuist files, and exactly one `type: application` target

## 2. Add a module

Pick the layer from the placement table in SKILL.md, then:

```sh
LAYER=bm                      # lib | bm | fm
NAME=Catalog                  # the module name; the directory is $LAYER-$NAME

mkdir -p "Packages/$LAYER-$NAME/Sources/$NAME" "Packages/$LAYER-$NAME/Tests/${NAME}Tests"
cp "$SKILL/templates/packages/$LAYER-Package.swift" "Packages/$LAYER-$NAME/Package.swift"
sed -i '' "s/__NAME__/$NAME/g" "Packages/$LAYER-$NAME/Package.swift"
```

Then, by hand:

1. Uncomment and fill this module's real dependencies in its `Package.swift` — both the
   `.package(path:)` entries and the matching `.product(name:package:)` entries.
2. Add it to `packages:` in `project.yml`, and to the app target's `dependencies:` if the shell
   uses it.
3. Write the sources under `Sources/<Name>`.
4. Write the tests. A `bm-` or plain `lib-` module **must** have a Swift Testing `@Test`; the
   gate fails without one. A `fm-` module or a UI library may delete the test target and its
   `Tests/` directory rather than leave an empty one.
5. `make verify`.

A UI library is iOS-only: drop macOS from its `platforms`. A `bm-` or plain `lib-` keeps both,
which is what lets `swift test` run it in seconds with no simulator.

## 3. Audit an existing project

The gate does the mechanical half. Install it first, even if you only intend to report:

```sh
cp -R "$SKILL/templates/ArchitectureTests" Packages/ArchitectureTests
sed -i '' "s/appName = \"App\"/appName = \"<TheApp>\"/" \
    Packages/ArchitectureTests/Tests/ArchitectureTests/ArchitectureConfig.swift
swift test --package-path Packages/ArchitectureTests 2>&1 | grep -o 'ARCH: .*' | sort -u
```

Every line it prints carries a `path:line`. Report them as they are.

Then read for what the gate cannot see:

- a `lib-` that imports a UI framework is a **UI library** — the problem is not that its tests
  got slower, it is that no `bm-` may now depend on it;
- a `bm-` whose public API exposes a third-party SDK's types;
- a feature reaching a sibling through a generic parameter or a closure handed up to the shell,
  rather than through a seam;
- domain logic sitting in a view or a view model that no `bm-` module can reach.

**Report, do not fix.** Findings are a list with `path:line`; fixing them is a separate decision
and a separate change. If asked to fix, fix the dependency — never the gate, the allowlist, the
platforms or the tests.
