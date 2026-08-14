# Nathan — C07 checkpoint feedback — 2026-08-14 (round 2)

**Commit graded: `4f77411` ("C07 update") · branch `checkpoint2` · supersedes the
2026-08-11 grading of `4199806` (that round is in this file's git history)**

## How to use this branch

- **Do not merge it.** Same rules as ever: read this doc, make every fix on `main`
  in your own commits.
- This branch grades **C7 codes only**. Your C6 grading lives on `checkpoint1` /
  `checkpoint-c06` and is unchanged.

## Score

| | |
|---|---|
| Cells claimed (21 codes × 3 features) | **35 / 63** |
| Confirmed | 27 |
| Short / weak | 3 |
| Rejected | 5 |
| **Provisional standing** | **≈ 27 / 63** |
| Quick wins available (see below) | → **~33** without writing new code |

## The headline: you banked the validation cells — then deleted three explain cells

The good move first: last round's quick win #1 is **done**. `C723a`/`C724a`/`C725a`
now sit on the actual existence/type/range checks in `base_motion.gd`, and with
`C735a`/`C745a` they make feature a's validation the strongest C7-3 work in the
class — genuinely all three checks, in the crash-proof order, on real free-text
input.

But the same commit **deleted your strongest C7-2 evidence**. The old
`circular_motion.gd` header — the FUNCTIONALITY / USE OF DATA / USE OF CODE
STRUCTURES block confirmed last round as C742a/C743a/C744a, 3 cells — is gone,
replaced by identify-level lines ("a simulation that simulates circular motion").
Feature a's documentation dropped from *explain* to *identify* in one commit.
C7-2 is 40% of the criterion; that deletion is why your provisional score is flat
at ≈27 despite the validation gains. It is fully recoverable — next actions, item 1.

Features b and c were not touched this round, so last round's five rejections
still stand: the C751 claims (scene tree contradicts "ALL"), C731c (default node
names), and the b-feature validation claims aimed at internal state.

## Verdicts

### Feature a — circular motion simulation (`circular_motion.gd` + `base_motion.gd`)

| Code | Skill | Verdict | Student's line (file:line) | What's missing |
|---|---|---|---|---|
| C711a | identifies naming conventions | **EARNED** | "variables and functions snake_case; constants UPPER_SNAKE_CASE…" (circular_motion.gd:2–4) | — open the Part B naming audit with this sentence |
| C712a | identifies functioning | **EARNED** | "a simulation that simulates circular motion / a homescreen for navigation / a settings screen…" (circular_motion.gd:6–9) | true; fix "FUNCTIONALALITY" and "customizablility" — clarity qualifiers bite at higher bands |
| C713a | identifies input data | **SHORT** | "User uses buttons, text boxes and sliders to change data" (circular_motion.gd:11–12) | the standard wants every input *named*: mass / radius / velocity (typed text + slider each), and the imported CSV file. Your own C713b (HomeScreen.gd:55) shows the required specificity |
| C721a | applies naming to variables | **SHORT** | "snake_case for variables and functionss" (circular_motion.gd:14–16) | this restates the convention — that's C711. Point the label at variable declarations, and fix the corners first: `tween_toggle` (booleans read as `is_`/`has_` questions), `target_pos`/`target_pos2`/`target_pos4`, and the magic `30.0` velocity scale (×3, circular_motion.gd:106/136/151) — name it `VELOCITY_SCALE` |
| C723a | existence checking | **EARNED** | "# EXISTENCE check: reject empty/whitespace-only input C723" → `if trimmed.is_empty()` (base_motion.gd:100–103) | — |
| C724a | type checking | **EARNED** | "# TYPE check… C724" → `if not trimmed.is_valid_float()` (base_motion.gd:104–106) | — |
| C725a | range checking | **EARNED** | "# RANGE check… C725" → `return clamp(value, min_value, max_value)` (base_motion.gd:110–111) | — |
| C735a | two checks working | **EARNED** | `try_parse_validated_float` chain (base_motion.gd:113–119, used circular_motion.gd:265–272) | — |
| C745a | all three checks | **EARNED** | same chain: existence → type → range on mass/radius/velocity text entry | minor inconsistency: rejection feedback is `push_warning` — editor console only, the player never learns why their value was ignored. Put it on a visible label. And **prove it fires**: type "abc", show the fallback |
| C742a C743a C744a | explains functionality / data / structures | **REMOVED** | — | confirmed last round, deleted this morning. Recover: `git show 4199806:circular_motion.gd`, copy the FUNCTIONALITY / USE OF DATA / USE OF CODE STRUCTURES block back under your new C711/C712 header, keep its labels |

### Feature b — home screen (`HomeScreen.gd`) — unchanged this round

| Code | Skill | Verdict | Student's line (file:line) | What's missing |
|---|---|---|---|---|
| C712b · C713b · C722b · C732b · C733b · C734b · C742b | documentation set | **EARNED** (all) | HomeScreen.gd:4, 55, 163, 141, 173, 154, 79 | — still your best-documented file |
| C721b · C731b · C741b | naming: variables, controls, structures | **EARNED** | HomeScreen.gd:103, 71, 157 | — |
| C723b | existence checking | **EARNED** | `if simulation not in SIMULATIONS:` (HomeScreen.gd:168) | — a real check on a user-driven value |
| C724b | type checking | **SHORT** | `if event is InputEventMouseButton:` (HomeScreen.gd:128–129) | event dispatch, not validation of a data input. Your real type check is C724a — drop or retarget this one |
| C725b | range checking | **REJECTED** | `if tabs.size() > 0:` (HomeScreen.gd:110) | guard on internal node list ≠ input range check — same category error as the C6 round |
| C735b | two checks | **REJECTED** | HomeScreen.gd:113–115 | built from the rejected range check above |
| C751b | naming on ALL elements | **REJECTED** | claim at HomeScreen.gd:7–9 | scene tree contradicts "ALL": `ReferenceRect4`, `Panel2`, a start "Button" that is actually a Panel (`start_button: Panel = $ReferenceRect4/Button`, line 73). File names are mixed too: `HomeScreen.gd`/`Global.gd`/`SelectablePanel.gd`/`tempBack.gd` vs the convention's snake_case (`base_motion.gd`), plus `switch2.gd` |

### Feature c — settings screen (`Settings.gd` + `switch.gd`) — unchanged this round

| Code | Skill | Verdict | Student's line (file:line) | What's missing |
|---|---|---|---|---|
| C712c · C722c · C733c · C734c · C742c · C743c · C744c | documentation set | **EARNED** (all) | Settings.gd:4, 21, 59, 89, 69; switch.gd:43, 6 | — the debounce explanation (C742c) is still your best single comment |
| C721c · C741c | naming: variables, structures | **EARNED** | switch.gd:15, 25 | note `cooldown` (Settings.gd:16) would fail the same test `tween_toggle` fails — booleans as questions |
| C731c | naming of interface controls | **REJECTED** | "$Panel / $Panel2 / $Sprite2D / $Sprite2D2 names describe exactly which visual layer…" (switch.gd:30–32) | they don't — they're Godot's default names, the reference's exact anti-pattern (`Button1`, `LineEdit`, `Label2`). Rename to `OnPanel`/`OffPanel`/`IconOn`/`IconOff` and this flips |
| C751c | naming on ALL elements | **REJECTED** | claim at Settings.gd:7–9 | `Control4`, `Panel4`, `speedSlider`/`speedLabel` (camelCase nodes), `Sprite2D2` |

## Unclaimed evidence — label these for free marks

- base_motion.gd:1 `class_name BaseMotionSimulation` + the verb-named
  `try_parse_validated_float` earn **C741a** — the cell you've held since last
  round, still unlabelled. One label.
- base_motion.gd:113–115 "Combines existence + type + range checks in one reusable
  helper so every subclass's callback stays short and consistent" — explain-level
  **C744a** prose, already written.
- base_motion.gd:88–93 "why: every value that can come from free-text user input…
  unlike slider input, which is already pre-clamped" — **C743a** explain-level
  use-of-data, already written.
- base_motion.gd:150–157 — `load_state_from_csv`'s malformed-file guards ("expected
  4 values", "non-numeric data — load aborted") are **completeness + type checking
  on the CSV source**: half of C753a, already working.

## Verb-ladder check (C7-2) and combination check (C7-3)

- **Ladder:** features b and c hold at *explain* (C742b, C742c, C743c, C744c are
  genuine whys). Feature a currently has nothing above *identify* — entirely
  because of the deleted header. C752 remains rightly unclaimed.
- **Combination:** C735a/C745a are the real thing. Feature b's combination claims
  are built from rejected parts — retire them; feature a already covers the
  combination codes.

## Top 3 next actions (biggest marks for least work)

1. **Restore the deleted explain header** — +3 cells, zero new writing:
   `git show 4199806:circular_motion.gd`, copy the C742a/C743a/C744a block back.
   While there: label C741a, C743a, C744a on the base_motion lines listed above.
2. **Retire the dead claims and do the rename.** Remove C724b/C725b/C735b and the
   two C751 claims, then rename the scene tree feature by feature —
   `ReferenceRect4` → `SummaryPanel`, `Control4` → `DarkModeSwitch`, `Sprite2D2` →
   `IconOff`, `speedSlider` → `SpeedSlider` — and unify file names
   (`HomeScreen.gd` → `home_screen.gd`, `tempBack.gd`, `switch2.gd`). The editor's
   right-click → Rename keeps references safe; commit per feature and say so in
   the message — that commit is itself naming and maintenance evidence. This flips
   C731c and makes all three C751 cells claimable instead of auto-rejected.
3. **Finish the validation summit:** name the inputs in C713a, write the one-
   sentence reasonableness rule beside the constants (why are MASS 0–20,
   RADIUS 2.5–10, VELOCITY ±60 sensible *physical* bounds? what breaks outside
   them?) → with the CSV completeness check you already have, that's **C753a** ✍️.
   Then make rejection visible to the player (label, not `push_warning`) and run
   the prove-it-fires test.

*Advisory only — marks are awarded live in Part B of the Live Coding Validation,
on a comment-stripped copy of one feature. C7-2 is where that test bites hardest —
the writing you restore must be writing you can reproduce.*
