# Checkpoint 1 — C6 Skill-Code Labelling — Grading

**Nathan · commit `4199806` · graded 2026-08-11 · branch `checkpoint1`**

## How to use this branch

- **Do not merge it.** Read the `# FB[...]` comments and this doc, then make every fix
  **on `main`, in your own commits**. Your commit history is part of your authenticity
  evidence — keep it yours.
- FB convention: **REJECTED** (claim doesn't stand — the comment says what would earn it)
  · **WEAK** (accepted for now; a stronger site or wording exists) · **RELABEL/MISLABEL**
  (right evidence, wrong code) · **note** (code quality) · **opportunity** (unlabelled
  work that would earn codes honestly).
- Line numbers below refer to `main` as you submitted it.

## What is being graded — read this part properly

This grade judges **the labelled artefact against the criteria — regardless of who or
what helped write it**. Using AI here is allowed and expected; log it in your AI
disclosure log. What AI cannot do for you is the next part: at the validation you work
on a comment-stripped copy, live, with the AI off. **Whether these labels survive that
is what decides your final level.** A label you can't re-derive and defend is worth
nothing on the day — so treat every fix below as something to *understand*, not just
apply.

## Score

| | |
|---|---|
| Cells claimed (of 34 codes × 3 features) | **67 / 102** |
| Sound as labelled | 50 |
| Weak / conditional | 11 |
| Rejected | 6 |
| **Provisional standing** | **≈ 56 / 102** |
| Realistic ceiling after the improvement list | **≈ 75 / 102** |

Final Stage-1 score is set after your improvement pass — this number is feedback, not a
verdict.

## What earned genuine credit

- **Your C645 row is the strongest in the class**: three *different* data-source
  rationales — CSV for persistence (a), in-memory constant for fixed menu data (b),
  autoload for cross-scene settings (c). Being able to contrast those three out loud is
  top-band reasoning.
- **The validation battery** in `circular_motion.gd` (:184–:206, :267–:303): existence,
  type and range as named, reusable helpers, applied to both free-text input and an
  untrusted CSV, with documented range constants. Your C745a claim stands.
- **`SIMULATIONS` as a dictionary of records** (b:17) with a written why — real C636.

## Verdict grid

✓ sound · ⚠ weak · ✗ rejected · — absent · *(reason on every non-✓)*

| Code | a (circular) | b (home) | c (settings) |
|---|---|---|---|
| C611 | — | — | ✓ |
| C612 | ✓ | — | — |
| C613 | ✓ | ✓ | ✓ |
| C614 | ✓ | — | ✓ |
| C615 | ✓ | ⚠ bare literal | ⚠ bare literal |
| C621 | ✓ | ✓ | ✓ |
| C622 | ✓ | ✓ | ✓ |
| C623 | ✓ | ✓ | ✓ |
| C624 | ✓ | — | ✓ |
| C625 | ✓ | — | ✓ |
| C626 | ✓ | ✓ | ✓ |
| C627 | ✓ | ✓ | ✓ |
| C628 | ✓ | ✓ | — |
| C629 | — *(your why-float prose at :70/:73 is unlabelled)* | ✓ | ✓ |
| C631 | ⚠ script member | ⚠ script member | ⚠ script member |
| C632 | ✓ | ✓ | — |
| C633 | ✓ | ✓ | ✓ |
| C634 | ✗ node ref | ✗ node ref | — |
| C635 | ⚠ format literal (real: :320) | ✓ | — |
| C636 | — | ✓ | — |
| C638 | — | — *(your 658b belongs here)* | ⚠ performance why |
| C641 | ✓ | ✓ | ✓ |
| C642 | ✓ | ✓ | ✓ |
| C643 | ✓ | ⚠ autogen name | ⚠ autogen name |
| C644 | ✓ | ✓ | ✓ |
| C645 | ✓ | ✓ | ✓ |
| C651 | — | — | — |
| C652 | — | — | — |
| C653 | — | — | — |
| C654 | — | — | — |
| C655 | — | — | — |
| C656 | ✗ engine-imposed | ✗ engine-imposed | ✗ engine-imposed |
| C657 | — | — | — |
| C658 | — | ⚠ relabel C638 | ✗ that's C744 |

## Improvement list, in order of value

1. **Label `SelectablePanel.gd`.** It is the only genuine OOP in your project and it is
   completely unlabelled — see the `FB[opportunity]` comment at the top of the file.
   Done with written whys, it opens the whole 9–10 band (C651–C655) for feature b.
2. **Type the variables in `Global.gd`, then claim C631/C634 there.** Your only true
   globals are currently untyped and unlabelled, while C631/C634 sit on script members
   and node references. This one fix repairs five weak/rejected cells.
3. **Three relabels:** C635a → the arrays at :320 · C658b → C638b · your why-float
   prose at :70/:73 → C629a.
4. **Drop C656 everywhere — or earn it in SelectablePanel** with a base-class design
   you can defend. Claiming it on `extends Control` at validation would cost you more
   than the code is worth.
5. **Two maintenance fixes that are themselves C734 evidence:** merge the doubled
   `if Global.dark_mode` blocks in `Settings.gd` (:31–:43), and delete the mangled
   comment fragment in `switch.gd` (:49).
6. **One sentence turns your range constants into a top-band claim:** write *why*
   `RADIUS_MIN 2.5` etc. are physically sensible bounds (what breaks outside them?) —
   that is the difference between range checking and *reasonableness* checking.

Everything still absent after this list (settings has no arithmetic, no iteration —
etc.) is **genuinely absent, and that's fine**. The score is meant to be true, not big.
Adding code that exists only to catch a tick earns nothing.

## Beyond the list — where the top band is genuinely yours to take

The list above stops near 75 because it only labels what already exists. Your own SRS
holds the door open to more, because **you still have four simulations to build**
(conical, orbital, projectile, vertical — currently empty scenes), and they all need
the same machinery circular motion already has: sliders wired to labels, validated
text input, a formula display, save/load, transport controls.

Copy-pasting `circular_motion.gd` four times would work — and would be the wrong
design, and you would have to defend that choice live. The right design is also the
one that opens the whole 9–10 band honestly:

- **A `Simulation` base class** holding the shared machinery, with each motion type
  supplying only its own formula and parameters. That is real, defensible
  **C651** (a class you designed), **C656** (inheritance you designed — exactly what
  the FB comment on line 2 says is missing), **C653** (abstraction: the base hides the
  machinery) and **C655** (generalisation: one design serving five simulations).
- Build even **one** more simulation on that base and every claim above has living
  proof: "here are two classes sharing it — watch me add a third parameter."
- **C657/C658** then follow almost by themselves, because your data story finally
  spans the range — CSV on disk, in-memory constants, autoload settings, a class
  hierarchy — explained across features, which is the 9–10 descriptor's actual wording.

None of that is tick-chasing — it is the next stretch of your own project plan, done
in the order that earns the most. The difference between 75 and beyond is not more
labels. It is one design decision, made early, that your MVP wanted anyway.
