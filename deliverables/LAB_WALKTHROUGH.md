# In-Lab Walkthrough

A per-session guide to claiming all 70 marks. It tells you what to load, what to
demo, and which document to read for each milestone. It does not repeat content:
follow the links.

Key references (open these alongside this file):
- **Deployment:** `usb/IMPORT_GUIDE.md` (version check, XML import, I/O-map paste,
  transfer, RUN, timer tuning).
- **Demo steps:** `08_lab_checklists/demo_checklists.md` (one tick-box list per
  milestone, 1:1 with the marked test protocol).
- **Schedule and prerequisites:** `08_lab_checklists/session_plan.md`.
- **Logbook content:** `logbook/LOGBOOK.pdf` (every milestone's writeup, FSM/block
  diagram, code, and a result box). Print it and use it as your logbook draft.

## What to bring

- The hardcopy A4 logbook (print `logbook/LOGBOOK.pdf`, or write into it).
- The USB with `usb/` on it (`plcopen/`, `st/`, `io_tables/`, `IMPORT_GUIDE.md`).
- A printout of `00_plan/gantt.xlsx` for P.1.

## The loop for every milestone

1. **Load** the program for that milestone (below) and set its `ROBUST` flag.
   First time on a station, follow `usb/IMPORT_GUIDE.md` sections 0–3 (import,
   bind the I/O map, transfer, RUN). After that, only the program and flag change.
2. **Tune** the timers if needed (`IMPORT_GUIDE.md` section 4). Start `t_stall` at
   `T#2s`.
3. **Demo** by running that milestone's list in `demo_checklists.md`, ticking each
   box as the tutor watches.
4. **Logbook:** have the matching FSM diagram and block diagram on the page (the
   `logbook/LOGBOOK.pdf` section, or the source doc named below). The writeup
   milestones need only the half-page.
5. **Claim** the milestone before moving on.

Claim milestones in the order below. Every session stays at or under the 15-mark
cap and every prerequisite is met by an earlier claim (`session_plan.md`).

---

## Session 1 (Week 2): P.1, 1.1–1.8 (14 marks)

Single-actuator milestones use the tiny drivers in
`usb/st/test_harnesses/` (see that folder's README). Paste one, bind the
Distributing I/O map (`usb/io_tables/distributing.tsv`), transfer, RUN.

- **P.1**: hand over the printed `00_plan/gantt.xlsx` plus the strategy and
  max-marks argument in `00_plan/gantt.md`.
- **1.1**: run the provided `distributing_station_tick_tock.smc2` sampler
  (Sysmac Quick-Start Guide, Part 1) and watch the arm move in CIROS.
- **1.2 / 1.3**: writeups only. Read `01_distributing/purpose.md` and
  `01_distributing/interface.md`; put the half-pages in your logbook.
- **1.4**: load `usb/st/test_harnesses/Test_Panel.st`. Demo the `1.4` list. Logbook:
  `01_distributing/fsm_panel.md` and `01_distributing/plc/FB_Panel.md` (FSM + ladder).
- **1.5 / 1.6**: load `usb/st/test_harnesses/Test_Arm.st` (`ROBUST := FALSE` then
  `TRUE`). Demo the `1.5`, then `1.6` list. Tune `t_stall` so a healthy swing does
  not trip Q2 but a 2 s hold does. Logbook: `01_distributing/fsm_T1.md`,
  `01_distributing/block_diagrams.md`, `01_distributing/plc/FB_Actuator_T1.md`.
- **1.7 / 1.8**: load `usb/st/test_harnesses/Test_EjectorT2.st` (`ROBUST` FALSE then
  TRUE). Demo `1.7`, then `1.8`. Logbook: `01_distributing/fsm_T2.md`, `01_distributing/plc/FB_Actuator_T2.md`.

## Session 2 (Week 3): 1.9, 1.10, 1.11, S1.1, S1.2, 2.1, 2.2, 2.3 (15 marks)

- **1.9 / 1.10**: load `usb/st/Main_Distributing.st` (or
  `usb/plcopen/distributing.xml`). Set `ROBUST := FALSE` for 1.9, `TRUE` for 1.10;
  re-transfer between them. Demo the `1.9`, then `1.10` list. Logbook:
  `01_distributing/block_diagrams.md` (4-block) and `01_distributing/plc/Main_Distributing.md`
  (sequence FSM).
- **1.11**: write the "after Station 1" revision note (`00_plan/gantt.md`,
  Revision notes section).
- **S1.1 / S1.2**: build the Ignition screen from
  `02_scada_S1/ignition_build.md` (tag map, screen, animation bindings). Demo per
  its Test section. Logbook: `02_scada_S1/purpose.md` for S1.1.
- **2.1**: writeup only. Read `03_testing/purpose.md`.
- **2.2 / 2.3**: move to the Testing suitcase. Bind the Testing I/O map
  (`usb/io_tables/testing.tsv`). Load `usb/st/test_harnesses/Test_Lift.st` (`ROBUST` FALSE
  then TRUE). Demo the `2.2 / 2.3` list. For 2.3, switch off the compressed air
  mid-travel to force the stall. This is `FB_Actuator_T1` reused unchanged.

## Session 3 (Week 4): 2.4–2.8, S2.1, S2.2 (15 marks)

- **2.4 / 2.5**: load `usb/st/test_harnesses/Test_EjectorT3.st` (`ROBUST` FALSE then
  TRUE). Demo `2.4 / 2.5`. Logbook: `03_testing/fsm_T3.md`,
  `03_testing/plc/FB_Actuator_T3.md`.
- **2.6 / 2.7**: load `usb/st/Main_Testing.st`. Set `ROBUST` FALSE then TRUE.
  **Verify the beam polarity first:** `Main_Testing` treats `beam_blocked := NOT
  Station_B4`; if the interlock reads inverted on the bench, flip that line
  (`03_testing/plc/Main_Testing.md`). Demo the `2.6`, then `2.7` list. Logbook:
  `03_testing/block_diagrams.md` (4-block + sequence) and `03_testing/plc/Main_Testing.md`.
- **2.8**: write the "after Station 2" revision note (`00_plan/gantt.md`).
- **S2.1 / S2.2**: build the Testing HMI from `04_scada_S2/ignition_build.md`
  (adds the colour/height readout and slide counts). Logbook:
  `04_scada_S2/purpose.md`.

## Session 4 (Week 5): 3.1–3.4, S3.1, S3.2, L.1 (15 marks)

- **3.1**: writeup only. Read `05_sorting/purpose.md`.
- **3.2 / 3.3**: Sorting suitcase. Bind the Sorting I/O map
  (`usb/io_tables/sorting.tsv`). Load `usb/st/Main_Sorting.st`, `ROBUST` FALSE then
  TRUE. Demo the `3.2` (proper), then `3.3` (robust) list. Logbook:
  `05_sorting/block_diagrams.md` (5-block + sequence) and `05_sorting/plc/Main_Sorting.md`.
- **3.4**: write the "after Station 3" revision note (`00_plan/gantt.md`).
- **S3.1 / S3.2**: build the Sorting HMI from `06_scada_S3/ignition_build.md`
  (colour/material readout, per-slide counts). Logbook: `06_scada_S3/purpose.md`.
- **L.1**: demonstrate that the same FB instances run on more than one station.
  No new code: confirm `FB_Panel` on all three, `FB_Actuator_T1` on Distributing +
  Testing, `FB_Actuator_T2` on Distributing + Sorting, `FB_Actuator_T3` on Testing
  + Sorting. Read `07_integrated/line_design.md` (L.1 reuse table).

## Session 5 (Week 6): L.2, L.3 (11 marks)

Wire the three suitcases together. Read `07_integrated/line_design.md` for the
handshake, master control, and error propagation, then:

- **L.2**: wire the `IP_FI` / `IP_N_FO` handshake between stations and route the
  Sorting panel's mode to all three (line_design.md, "Inter-station handshake" and
  "L.2"). Demo the `L.2` list.
- **L.3**: add the upstream `error_in` OR-links so Sorting error stops all three,
  Testing error stops Testing + Distributing (line_design.md, "L.3"). Demo the
  `L.3` list, clearing every fault from the Sorting panel only.

---

## Timer tuning cheat-sheet

Full detail in `usb/IMPORT_GUIDE.md` section 4.

- `t_stall` (robust FBs): raise if a healthy stroke trips a false Q2; lower if a
  real hold takes too long to catch. Start `T#2s`.
- `t_stroke` (T3 only): set just longer than the real extend travel, since that end
  has no limit switch. Start `T#700ms`.
- `ROBUST` in each `Main_*` / harness: `FALSE` for the "proper" claim, `TRUE` for
  the "robust" claim. Re-transfer between the two.

## If something misbehaves

- **Symbols show red / unresolved after import:** the I/O map is not bound. Do
  `IMPORT_GUIDE.md` section 2.
- **Beam interlock inverted (Testing):** flip `beam_blocked := NOT Station_B4` in
  `Main_Testing`.
- **A healthy actuator trips Q2:** `t_stall` is too short. Raise it.
- **Actuator never reports "at end" (T3):** `t_stroke` is too short for the real
  extend travel. Raise it.
- **PLCopen import unavailable (Sysmac < v1.30):** use the paste fallback,
  `IMPORT_GUIDE.md` "Fallback path".
