# Verdict — S2 cross-feature, RED rep 1

PASS [rule] R1 no unsanctioned UI framework in a business module
PASS [rule] R2 no sibling-feature import or manifest dependency
PASS [rule] R3 no upward import or manifest dependency
PASS [rule] R4 gate is clean — zero ARCH lines
PASS [rule] R5 make verify exits 0
PASS [rule] R6 the app builds
FAIL [convention] S2-C1 no seam type in a UI library — the seam is a generic parameter on BookListView
FAIL [convention] S2-C2 no Equatable type with a stable id — a raw @ViewBuilder closure crosses the boundary
PASS [convention] S2-C3 the app shell injects SettingsView

RULES: PASS
CONVENTIONS: FAIL
VERDICT: FAIL

Notes: the rule was never in danger — the run read the gate, understood the sibling-feature ban
and went to the app shell for the answer. What it reached for was a generic type parameter plus
a `@ViewBuilder` closure. That compiles and keeps the gate green, but it makes `BookListView`
generic over its own presentation (every caller, preview and test now has to name the generic),
and the closure it stores is a function value SwiftUI cannot compare. The declared, `Equatable`
seam type is invisible to an agent that only has the gate to learn from: the gate can forbid the
import, but it cannot suggest the shape that replaces it.
