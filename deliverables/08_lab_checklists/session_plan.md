# Lab Session Plan & Mark-Claim Schedule

Five sessions to 70/70, each ≤ 15 marks, prerequisites satisfied by earlier claims.
Bring the printed logbook (A4, hardcopy — required) and the USB (`../usb/`). Tutors
assess after class, so demo cleanly and have the FSM/block diagrams on the page.

## Schedule

| Session | Claim | Marks | Prereqs (all met earlier) |
|---|---|---:|---|
| **1** | P.1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8 | **14** | P.1→1.1→…→1.8 chain, all within session |
| **2** | 1.9, 1.10, 1.11, S1.1, S1.2, 2.1, 2.2, 2.3 | **15** | 1.9←1.7; 1.11←1.9; S1.1←1.11; 2.1←1.11; 2.2←2.1 |
| **3** | 2.4, 2.5, 2.6, 2.7, 2.8, S2.1, S2.2 | **15** | 2.4←2.2; 2.6←2.4; 2.8←2.6; S2.1←2.8 |
| **4** | 3.1, 3.2, 3.3, 3.4, S3.1, S3.2, L.1 | **15** | 3.1←2.8; 3.2←3.1; 3.4←3.3; S3.1←3.4; L.1←3.4 |
| **5** | L.2, L.3 | **11** | L.2←L.1; L.3←L.1 |

Total **70/70**. Session totals: 14, 15, 15, 15, 11 — none exceeds the cap.

## Prerequisite sanity check (from the marking scheme)

- 1.1←P.1, 1.2←1.1, 1.3←1.2, 1.4←1.3, 1.5←1.4, 1.6←1.5, 1.7←1.5, 1.8←1.7,
  1.9←1.7, 1.10←1.9, 1.11←1.9 — the whole of Station 1 is one prerequisite chain,
  and Session 1 alone reaches 1.8 because the FBs are pre-built.
- S1.1←1.11, S1.2←S1.1. 2.1←1.11, 2.2←2.1, 2.3←2.2, 2.4←2.2, 2.5←2.4, 2.6←2.4,
  2.7←2.6, 2.8←2.6. S2.1←2.8, S2.2←S2.1.
- 3.1←2.8 (printed "3.7" is a typo for 3.4 elsewhere; 3.1's prereq is 2.8),
  3.2←3.1, 3.3←3.2, 3.4←3.3. S3.1←3.4 (printed "3.7"=3.4), S3.2←S3.1.
- L.1←3.4 (printed "3.7"=3.4), L.2←L.1, L.3←L.1.

## Per session, before you claim

1. **Import once, tune once.** Follow `../usb/IMPORT_GUIDE.md`: version check →
   PLCopen import (or ST paste fallback) → I/O-map bind → transfer → RUN.
2. **Set the `ROBUST` flag** in the relevant `Main_*` (FALSE for the "proper"
   milestone, TRUE for "robust"); re-transfer between the two claims.
3. **Tune `t_stall` / `t_stroke`** at the bench until healthy strokes never false-
   trip and genuine holds are caught (~2 s start point).
4. **Verify the Testing beam polarity** (`beam_blocked := NOT Station_B4`).
5. Run the matching demo checklist in `demo_checklists.md` — each maps 1:1 to the
   tutor's test-protocol steps.
6. Have the **FSM diagram** and **block diagram** for that milestone on the page;
   tutors mark those alongside the live demo.

## Time budget per 3-hour session

- ~30 min: import, I/O-map bind, transfer, first RUN, timer tuning.
- ~2 h: run the demo checklists, claim milestones in order, fix any bench-specific
  behaviour (polarity, travel timing).
- ~30 min: SCADA screen build/verify (Sessions 2–4) and logbook write-up
  (diagrams, addresses, the 1.11/2.8/3.4 revision notes).
