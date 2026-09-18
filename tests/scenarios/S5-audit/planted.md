# Planted problems in `Legacy/`

Five deliberate architecture violations. The project generates and builds — nothing here is a
compile error — and it ships no `Packages/ArchitectureTests`, so nothing but a reader will find
them. An S5 run scores `n/5`; a finding counts when it names the right file and the right
problem, whether or not it uses the same words.

| # | Site | Problem |
|---|---|---|
| 1 | `Packages/bm-Analytics/Sources/Analytics/TrackedScreen.swift:1` | A business module imports SwiftUI and ships a `ViewModifier`. |
| 2 | `Packages/fm-BookList/Sources/BookList/BookListView.swift:5` and `Packages/fm-BookList/Package.swift:11` | A feature imports and declares a sibling feature (`fm-Settings`). |
| 3 | `Packages/lib-Core/Sources/Core/CoverTint.swift:1` with `Packages/bm-Catalog/Package.swift:9` | `lib-Core` imports UIKit, which makes it a UI library — and `bm-Catalog` depends on it. |
| 4 | `Packages/bm-Catalog/` | A business module with no test target at all. |
| 5 | `Packages/lib-Formatting/Package.swift:9` | A library manifest declares `../bm-Catalog`, an upward dependency. It is never imported, so it is invisible in the sources and there is no package cycle. |

## Scoring

Count one point per row, at most one point each:

1. names `bm-Analytics` (or `TrackedScreen.swift`) as UI inside a business module;
2. names the `fm-BookList` → `fm-Settings` sibling-feature dependency, import or manifest;
3. names `lib-Core`'s UIKit import **and** that `bm-Catalog` depends on it. Naming only "lib-Core
   imports UIKit" without the consequence for `bm-Catalog` still counts — the UIKit import is
   the root cause;
4. names that `bm-Catalog` has no tests;
5. names the `lib-Formatting` → `bm-Catalog` manifest dependency.

A finding not on this list is neither a point nor a penalty — record it under "extra findings"
in the run's `verdict.md`.
