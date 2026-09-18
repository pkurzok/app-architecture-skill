# Verdict — S5 audit, RED rep 1

Scored against `tests/scenarios/S5-audit/planted.md`.

PASS [rule] planted 1 — UI in a business module: finding 8 names `TrackedScreen.swift:1`
PASS [rule] planted 2 — sibling feature: findings 4 and 5 name both the manifest and the import
PASS [rule] planted 3 — lib-Core imports UIKit: finding 6 names `CoverTint.swift:1` (root cause; it does not draw the consequence for bm-Catalog, which planted.md allows)
PASS [rule] planted 4 — bm-Catalog has no tests: finding 1
PASS [rule] planted 5 — lib-Formatting declares ../bm-Catalog: findings 2 and 3
PASS [convention] S5-C1 every finding carries a path:line

RULES: PASS — 5/5
CONVENTIONS: PASS
VERDICT: PASS

Extra findings, neither credited nor penalised:

- 7: `CoverTint.color(for:)` is dead code. True, and a consequence of how the fixture was built.
- 9: the app wires `InMemoryAnalyticsSink` in production. True of the demo too — the shell has
  no real backend to point at.
- 10: `.swiftlint.yml` mentions an `ArchitectureTests` registry that this project does not have.
  The sharpest of the three: the comment is a fossil of a gate that was removed, and the run
  read it as evidence that *"layering rules are unenforced"* — which is exactly the state the
  fixture was built to represent.

Notes: a clean unaided 5/5 on a project whose prefixes already announce the layers. Reading
`lib-`, `bm-`, `fm-` and inferring that dependencies must point down is not something the skill
needs to teach; the fixture teaches it. What no baseline can do here is name the rule that makes
`lib-Core` a *UI library* rather than just an awkward import — finding 6 stops at the testing
cost.
