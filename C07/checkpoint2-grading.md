# Checkpoint 2 — C7 Skill-Code Labelling — Grading

**Nathan · commit `4199806` · graded 2026-08-11 · branch `checkpoint2`**

## How to use this branch

- **Do not merge it.** Same rules as `checkpoint1`: read the `FB[...]` comments and
  this doc, make every fix on `main` in your own commits.
- **This branch grades C7 codes only** (naming · internal documentation · input
  validation). The ✓ ticks here mark confirmed **C7** labels; your C6 grading lives
  on `checkpoint1` and is unchanged.
- C07 opens properly in a few days — you are ahead, having labelled C7 already.
  This feedback is so your head start becomes a real one.

## Score

| | |
|---|---|
| Cells claimed (21 codes × 3 features) | **34 / 63** |
| Confirmed | 26 |
| Weak | 1 |
| Rejected | 7 |
| **Provisional standing** | **≈ 27 / 63** |
| Quick wins available (see below) | → **~33** without writing new code |

## The headline: your documentation is strong, your naming claims overreach

**C7-2 (internal documentation) is your best indicator anywhere in the SAT** — 16 of
16 claims confirmed. The functionality/data/structures header in
`circular_motion.gd`, the debounce explanation in `Settings.gd`, and the
state-vs-animation split in `switch.gd` are genuine *explain*-level writing. Two
tracked TODOs are real maintenance evidence.

The pattern in what failed: **C7-1's top band was claimed while the scene tree
contradicts it.** All three C751 claims ("suitable naming for ALL solution
elements") fail on the same evidence — `Control4`, `ReferenceRect4`, `Panel2`,
`Sprite2D2`, `Button2`, camelCase node paths against snake_case variables. Your
*variable* naming genuinely is good; that is C721, and it is confirmed. C751 needs
the scene tree brought to the same standard, or the claim dropped.

And C7-3 repeated a C6 mistake: **guards on internal state claimed as input
validation** (C724b/C725b/C735b). The real input validation — your text boxes and
CSV load — is the strongest C7-3 work in the class and sits under-claimed.

## Verdict grid

| Indicator | Confirmed ✓ | Rejected ✗ / weak ⚠ | Unclaimed |
|---|---|---|---|
| **C7-1 naming** | C711a · C721b · C721c · C731b · C741b · C741c | ✗ C741a (autogen name, wrong wording) · ✗ C731c (default node names) · ✗ C751a/b/c (scene tree contradicts "ALL") | C711b/c, C721a, C731a, C741— honest gaps |
| **C7-2 documentation** | C712b/c · C722b/c · C732b · C733b/c · C734b/c · C742a/b/c · C743a/c · C744a/c — **all 16 stand** | — | C712a, C722a, C732a/c, C743b, C744b, **C752 (rightly unclaimed — "ALL, clear and concise" is not yet true)** |
| **C7-3 validation** | C713b · C723b · C735a · C745a | ✗ C725b/C735b (state guards ≠ input validation) · ⚠ C724b (event dispatch) | C713a/c, **C723a/C724a/C725a — see quick wins** · C753 |

## Quick wins — cells you already earned but never claimed

1. **C723a, C724a, C725a — three free cells.** Your validation helpers *literally
   implement* existence, type and range as named functions. Label each check where
   it happens. (This also fixes the C7-3 category error: point the claims at real
   input, drop the HomeScreen guards.)
2. **C741a → `_try_parse_validated_float`.** You hold C741; you labelled the wrong
   site with the wrong wording. One move.
3. **C753 is one sentence away** — same sentence as checkpoint1's improvement item 6:
   *why* are `RADIUS_MIN 2.5` etc. sensible physical bounds? What breaks outside
   them? That turns range checking into reasonableness checking.

## The bigger move, when C07 opens

**Rename the scene tree** (`Control4` → what it actually is, `Sprite2D2` →
`IconOff`, …) and C751 plus C731c stop being rejections and become real claims.
It is tedious, honest work the editor makes safe (right-click → Rename, references
update). Do it feature by feature and say so in a commit message — that commit *is*
naming-convention evidence.

A writing guide arrives when C07 opens. Check your existing one-line labels
against it — your `a`-feature writing is at the bar; some `c`-feature lines are not.

The same rule as ever: this grades the artefact. Whether the writing is yours is
tested live, on a stripped copy, with the AI off — and C7-2 is the indicator where
that test bites hardest.
