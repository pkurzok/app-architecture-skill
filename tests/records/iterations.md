# Iterations

What changed between RED and GREEN, what each change was answering, and what happened.

## Iteration 1 — 2026-09-18

The only iteration. Thirteen runs, thirteen `VERDICT: PASS`, so there was no REFACTOR pass to
record. What follows is therefore the *design* of iteration 1 rather than a repair log, plus the
two methodology corrections the iteration forced.

### What the skill was written against

Straight from `baseline.md`. Each failure got the form the `superpowers:writing-skills` guidance
prescribes for its failure *type*, which is not the same form in every case:

| Baseline failure | Type | Form chosen | Where |
|---|---|---|---|
| S1, S2: legal but wrong-shaped answer (generic parameter, raw closure, per-call-site wiring) | output shape | **positive recipe** — a complete, compiled example of the shape that is wanted | `reference/feature-seams.md`, pointed at from two "common mistakes" bullets |
| S4: omitted the whole skeleton | omission | **structural checklist** — a list of files that must exist, ticked off | `reference/workflows.md` §1 |
| S5: could not name the derived-UI-library rule | missing concept | **statement of the rule plus its consequence** | SKILL.md "The rules" |
| S3: discipline under pressure | discipline | **prohibition + red flags** | SKILL.md "Boundary exceptions" |

Only S3 got the prohibition form. S1 and S2 deliberately did **not**: the guidance says a
prohibition backfires on a shaping failure, because an agent under a competing incentive
negotiates with "don't X". The RED runs bear that out — all six reps already knew they must not
import a sibling, and still produced the wrong shape. There was nothing left to forbid; what was
missing was a picture of the right answer.

### Result

| Scenario | Reps | Rules | Conventions |
|---|---|---|---|
| S1 placement | 3 | 3/3 | **3/3** (RED: 0/3) |
| S2 cross-feature | 3 | 3/3 | **3/3** (RED: 0/3) |
| S3 pressure | 5 | 5/5 | n/a (RED: 6/6, also passing) |
| S4 scaffold | 1 | 1/1 | **1/1** (RED: 0/1) |
| S5 audit | 1 | 5/5 | 1/1 |

Variance is the useful signal here: all three S1 reps produced the same file in the same place,
and all three S2 reps compiled a `SettingsContent` that is byte-identical to the recipe. Reps
converging on one shape is what "the wording is binding" looks like; five different readings
would have meant the opposite.

### Correction 1 — the test harness leaked the answer key

The first S1 GREEN run was pointed at `skills/app-architecture/SKILL.md` **inside this checkout**,
the same tree that holds `tests/scenarios/criteria.md`. The run's report cited
`S1-R7`, `S1-C1`, `S1-C2`, `S1-C3` — identifiers that exist nowhere but the criteria file. It had
read its own grading rubric.

That run was **voided and re-run**, and every GREEN run since points at an isolated copy of
`skills/app-architecture/` in the scratch directory, with no tests, no criteria and no records
reachable from it. A skill that is tested inside its own test repository is not being tested.

### Correction 2 — `S1-C3` was not decidable for a correct answer

`S1-C3` originally read *"the `bm-Analytics` screen API has a test"*, which assumes the run adds
an API to the business module. All three RED reps did. All three GREEN reps did not: the seam
closure calls the existing `track(event:)` from the app shell, so `bm-Analytics` is byte-identical
to the fixture and there is no new API to test.

Scoring that as a failure would have punished the better answer. The criterion now reads: if the
business module is unchanged, the run added no business API and this passes; if it changed, the
new API must have a test. This is a **criteria correction, not a skill change** — SKILL.md and
both reference files were untouched.

### Two things the runs got slightly wrong, left as they are

- S3 green-i1-2 wrote that *"business modules can't get that exception at all"*. They can: the
  `// ui-boundary:` marker is valid in `bm-` and `lib-` alike, it just needs the human's sign-off.
  The run's conclusion was right and its reasoning overshot in the safe direction. Tightening
  SKILL.md to correct an over-refusal would risk trading it for an under-refusal, which is the
  failure that actually costs something.
- S5 green-i1-1 listed a missing `AGENTS.md` as `AGENTS.md:1`, a line number for a file that does
  not exist. Harmless, and the output contract asked for `path:line` on every row.
