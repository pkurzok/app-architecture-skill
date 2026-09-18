# Verdict — S2 cross-feature, RED rep 2

PASS [rule] R1 no unsanctioned UI framework in a business module
PASS [rule] R2 no sibling-feature import or manifest dependency
PASS [rule] R3 no upward import or manifest dependency
PASS [rule] R4 gate is clean — zero ARCH lines
PASS [rule] R5 make verify exits 0
PASS [rule] R6 the app builds
FAIL [convention] S2-C1 no seam type in a UI library — an `onSettingsTapped: () -> Void` callback on BookListView
FAIL [convention] S2-C2 no Equatable type with a stable id
PASS [convention] S2-C3 the app shell owns the sheet and builds SettingsView

RULES: PASS
CONVENTIONS: FAIL
VERDICT: FAIL

Notes: the rule held again, by a different route: the callback goes up instead of the content
coming down. The cost is that the sheet no longer belongs to the screen that presents it — the
`.sheet` modifier moved to `ShelfApp`, so the book list has a gear button that reports a tap and
knows nothing about what happens next. Every future presentation from this screen adds another
boolean and another modifier to the composition root.
