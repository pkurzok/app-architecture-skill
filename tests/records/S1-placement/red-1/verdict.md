# Verdict — S1 placement, RED rep 1

PASS [rule] R1 no unsanctioned UI framework in a business module
PASS [rule] R2 no sibling-feature import or manifest dependency
PASS [rule] R3 no upward import or manifest dependency
PASS [rule] R4 gate is clean — zero ARCH lines
PASS [rule] R5 make verify exits 0
PASS [rule] R6 the app builds
PASS [rule] S1-R7 bm-Analytics still declares macOS and its swift test passes
PASS [convention] S1-C1 hook declared in a UI library (lib-DesignSystem/TrackScreenView.swift)
FAIL [convention] S1-C2 not injected by the app shell — each screen passes its own Analytics value, App/Sources untouched
PASS [convention] S1-C3 bm-Analytics has a screen_view test

RULES: PASS
CONVENTIONS: FAIL
VERDICT: FAIL

Notes: the run found the layering constraint unaided and solved it with a UI-free protocol in
`lib-Core` plus a modifier in `lib-DesignSystem`. What it did not do is treat the app shell as
the place that supplies behaviour: it threaded an `Analytics` value through the view models and
out to each view instead, which makes every new screen a two-place change (a parameter and a
call) rather than a one-liner.
