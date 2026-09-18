---
name: app-architecture
description: Use when creating, restructuring or reviewing an iOS or macOS app that is split into Swift Package modules — adding a module, deciding whether code belongs in a feature, business or library module, editing Package.swift dependencies or project.yml, showing one feature's screen from another, adding a third-party SDK, or when an architecture test reports an upward import, a sibling feature import or a UI framework in a business module.
---

# App architecture: Feature / Business / Library modules

## Overview

Every module is a Swift package under `Packages/`; its directory prefix is its layer:

- **App shell** (`App/Sources`) — the composition root: imports anything, builds the objects, injects the seams.
- **Feature `fm-`** — one screen or flow: views and view models.
- **Business `bm-`** — domain types, persistence, networking, SDK wrappers. **Renders nothing.**
- **Library `lib-`** — domain-agnostic helpers, and reusable UI.

Dependencies point down, and Business never knows UI — the golden rule, and what lets a business
module run its tests in seconds with no simulator.

## The rules

```text
            may import →   App   fm-   bm-   lib- (plain)  lib- (UI)   UI framework
App shell                   –     ✓     ✓        ✓             ✓            ✓
fm-  Feature                ✗     ✗ ¹   ✓        ✓             ✓            ✓
bm-  Business               ✗     ✗     ✓        ✓             ✗            ✗ ²
lib- Library                ✗     ✗     ✗        ✓       ✓ → becomes UI   ✓ → becomes UI ²

¹ never a sibling feature — use a seam injected by the app shell
² unless the import carries `// ui-boundary: <reason>` AND the file is in the allowlist
```

A **UI library is derived, never declared**: a `lib-` that imports a UI framework, or a UI
library, *is* one. No `bm-` may import or declare one. There is no fifth prefix.

Module name = directory minus its prefix: unique across the repo, never the app's name, never an
Apple framework's name. One `Package.swift` per module, product named for it, sources in
`Sources/<Name>`.

## Where does this code go?

| The code… | Goes in |
|---|---|
| renders pixels, or is a view model | `fm-` |
| is a domain type, store, repository, network client or SDK wrapper | `bm-` |
| is a domain-agnostic helper: dates, formatting, ids | plain `lib-` |
| is a reusable view, style or design token | UI `lib-` |
| is shared UI that needs business behaviour | hook in a UI library, behaviour injected by the app |
| uses a mixed framework — MapKit, StoreKit, WidgetKit, AVFoundation | `bm-`, using only its non-UI API |

## Workflows

Start a project, add a module, audit an existing one: `reference/workflows.md`, each ending in
`make verify`. Read it before scaffolding or auditing — the scaffold is a checklist, and a
project missing part of it will not hold the pattern.

## Third-party

Declare a dependency in the module that consumes it, never centrally. Wrap each heavy SDK in one
`bm-` module whose public API names no SDK type, so replacing the vendor stays one
module's problem. A third-party *view* library is a UI framework: add it to `extraUIFrameworks`.

## Boundary exceptions

**Never make a red gate green by widening what you are allowed to do.**

Never add any of these to turn `make verify` green:

- a `// ui-boundary:` marker, or an `ArchitectureConfig.uiBoundaryAllowlist` entry
- an `extraUIFrameworks` edit, or any change under `Packages/ArchitectureTests`
- a platform change, a package rename, or a re-prefix
- a change to `Makefile`, `scripts/test-all.sh` or `.swiftlint.yml`
- a deleted, skipped or disabled test

Fix the dependency instead: move the offending type to the feature that renders it, or to a UI
library. If it cannot move, **stop and ask** — a boundary exception is the human's decision. You
may propose one, never take it.

A sanctioned import is narrow: marker plus allowlist entry means the gate ignores that one line,
so the `bm-` stays legal and the `lib-` stays plain. In a module that declares macOS it must sit
inside `#if canImport(UIKit)`, or the module drops macOS and loses the fast test run.

### Red flags — stop and ask

- "just this once, to unblock the demo"
- "CI is blocking the release branch"
- "the gate is too strict here"
- "I'll add the allowlist entry and we can review it later"
- "the platform line is the real problem"

## Project generation

XcodeGen generates the project from a committed `project.yml`. The `.xcodeproj` is gitignored,
never hand-edited, never committed. **No Tuist, no demo or sample app target.**

Xcode 27.2 can store a project as JSON (`project.xcproj`) rather than `pbxproj`. It changes
nothing here: the project is generated, so its format is an implementation detail.
`apple/xcode-project-format` is a reader and formatter, not a generator. Never convert the
project, never commit it.

## Common mistakes

- **Reaching a sibling's screen with a generic parameter, or handing a closure up to the shell.**
  Declare a seam type instead — `reference/feature-seams.md` has the recipe.
- **Tying a shared UI hook to business behaviour at each call site.** The UI library declares the
  hook; the app shell supplies the behaviour, once.
- **Scaffolding without the skeleton.** Layer prefixes, `Makefile`, `scripts/test-all.sh`,
  `Packages/ArchitectureTests` and `AGENTS.md` carry the pattern to the next module and author.

Credit: strongly inspired by the [JET modular architecture](https://albertodebortoli.com/2026/07/15/revisiting-the-jet-ios-modular-architecture-in-2026/)
— not a copy: it adds a Business layer, with no demo apps and no Tuist.
