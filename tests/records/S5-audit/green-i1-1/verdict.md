# Verdict — S5 audit, GREEN iteration 1, rep 1

Scored against `tests/scenarios/S5-audit/planted.md`.

PASS [rule] planted 1 — UI in a business module: finding 6
PASS [rule] planted 2 — sibling feature: findings 1 (manifest) and 2 (import)
PASS [rule] planted 3 — lib-Core imports UIKit **and** bm-Catalog depends on it: findings 4 and 5
PASS [rule] planted 4 — bm-Catalog has no tests: finding 8
PASS [rule] planted 5 — lib-Formatting declares ../bm-Catalog: finding 3
PASS [convention] S5-C1 every finding carries a path:line

RULES: PASS — 5/5
CONVENTIONS: PASS
VERDICT: PASS

The difference from the baseline is finding 5. The RED run reported `lib-Core`'s UIKit import as
a *testing* cost — "forces domain-agnostic lib-Core off fast macOS testing" — and stopped there.
This run names the rule and then draws the consequence in the next line:

> 4. `…/CoverTint.swift:1` — "plain" lib-Core imports UIKit, becoming an **undeclared UI library**.
> 5. `…/bm-Catalog/Package.swift:9` — Business module bm-Catalog depends on lib-Core, **now a UI library**.

That is the derived-UI-library rule doing the work: the import is not the problem by itself, it
is what the import turns `lib-Core` into, and what that makes illegal downstream.

Extra findings, neither credited nor penalised: 7 (bm-Catalog is iOS-only and loses the fast test
run — a true consequence of the same decay), 9 (no ArchitectureTests package, so nothing enforces
any of this), 10 (no AGENTS.md), 11 (`PublicationYear` overlaps `lib-Formatting`'s purpose —
a judgement call, and a fair one).
