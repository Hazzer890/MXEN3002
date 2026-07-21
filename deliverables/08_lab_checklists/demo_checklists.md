# Per-Milestone Demo Checklists

Each checklist maps **1:1 to the steps in `MXEN3002_Station_Test_Sequences.pdf`**.
Each box is a numbered step of the station test protocol; against the finite-state
diagrams the design already meets each one. In the lab you are confirming the real
hardware matches. Tick as you demo.

Global rule (all tests): start/reset only from Pause; Start light on = Run, off =
Pause; Reset light on = Reset; one operational light at a time; Q2 = error, all
valves off; clear an error with the reset sequence.

---

## Milestone 1.4 — Control panel
- [ ] Power on → **Pause**, all lights off.
- [ ] Start (S1) in Pause → **Run**, Start light on.
- [ ] Stop (S2) in Run → **Pause**, Start light off.
- [ ] Reset (S4) in Pause → **Reset**, Reset light on.
- [ ] Stop (S2) in Reset → **Pause**, Reset light off.
- [ ] Start (S1) in Reset → **no change**; Reset (S4) in Run → **no change**; never
  both lights on.

## Milestone 1.5 — Swivel arm proper
- [ ] Reset with arm in-between → arm returns to **home (magazine)**.
- [ ] Run → arm travels end↔home **continuously**.
- [ ] Stop mid-swivel (forward) → arm **stops immediately**; Start → **resumes to
  end**, no jerk/return-home. (Repeat backward.)
- [ ] Start, Stop mid-way, Reset → sequence aborts, arm returns **directly home**.

## Milestone 1.6 — Swivel arm robust
- [ ] Home→End: hold arm mid-swivel > 2 s → **Q2 on**, arm stops.
- [ ] End→Home: hold arm mid-swivel > 2 s → **Q2 on**, arm stops.
- [ ] Start in Error → **no change**.
- [ ] Reset then Start → arm moves **continuously** again.

## Milestone 1.7 — Ejection cylinder proper
- [ ] Reset in Pause → cylinder **retracts fully home**.
- [ ] Run → extends fully and retracts **continuously**.
- [ ] Stop mid-travel → cylinder does **NOT** stop mid-stroke; completes to a limit
  then halts in Pause. (Both directions.)
- [ ] Start after halt at a limit → **next stroke** begins.

## Milestone 1.8 — Ejection cylinder robust
- [ ] Home→End: hold / air off mid-travel > 2 s → **Q2 on**, valves off, stops.
- [ ] End→Home: same → **Q2 on**.
- [ ] Start in Error → **no change**.
- [ ] Reset then Start → moves **continuously** again.

## Milestone 1.9 — Distributing proper
- [ ] Reset + load 5 → arm home, ejector retracted.
- [ ] Run → 7-step loop ×5: arm downstream → ejector push → arm upstream → vacuum →
  ejector retract → arm to end → drop+vacuum off.
- [ ] After 5th piece → **Q1 on**, both actuators home, vacuum off, **stays in
  Run**.
- [ ] Pause while arm to delivery → arm **stops immediately**, ejector finishes
  stroke; Start → resumes exactly where left off.
- [ ] Pause while arm to pickup → same; Start → resumes.

## Milestone 1.10 — Distributing robust
- [ ] Hold swivel arm > 2 s → **Q2 on**.
- [ ] Hold ejection cylinder > 2 s → **Q2 on**.
- [ ] Pull piece off vacuum while active → **Q2 on**.
- [ ] Arm reaches magazine with no piece available → **Q2 on**. (In Error, all
  valves off.)

---

## Milestone 2.2 / 2.3 — Lift proper / robust — reuses FB_Actuator_T1
- [ ] 2.2: same as 1.5 (pause/resume/reset), lift as the actuator.
- [ ] 2.3: same as 1.6 — switch off compressed air mid-cycle to stall → **Q2**.

## Milestone 2.4 / 2.5 — Testing ejector proper / robust — FB_Actuator_T3
- [ ] 2.4: same as 1.7 (completes stroke on pause). Single retract sensor; extend
  by timer.
- [ ] 2.5: same as 1.8 — held/air-off caught on the retract leg → **Q2**.

## Milestone 2.6 — Testing station proper
- [ ] 3 **white**: lift to height sensor, then **reject to bottom slide**.
- [ ] 3 **red/metal**: lift to upper position, **transfer to top slide**, **blower
  on ~1 s** during slide movement.
- [ ] 3 **black**: lift does **not** move, **reject immediately to bottom slide**.
- [ ] Normal reset → lift to bottom home, ejectors retract.
- [ ] Pause mid-lift (up and down) → lift **freezes**; Start → resumes.

## Milestone 2.7 — Testing station robust
- [ ] Bottom slide full (3 black + 2 white) → **Q1 on**.
- [ ] White with slide full → stops at entry after height check, **Q2**, reset
  required.
- [ ] Non-white with slide full → pushed to **top slide**, station **stays in Run**.
- [ ] Hold lift > 2 s (up and down) → **Q2**.
- [ ] Beam blocked during prep for up/down → lift **stationary**; blocked > 3 s →
  **Q2**, error state.

---

## Milestone 3.2 — Sorting station proper
- [ ] Process 2 red, 2 metal, 2 black **separately** → slides 2, 1, 3.
- [ ] Any slide full → **Q1 on and station → Error**.
- [ ] Normal reset → all actuators home.
- [ ] Pause while a branch mid-travel → **completes stroke to end** then stops
  (home→end and end→home); Start → resumes.
- [ ] Pause with a piece on the conveyor → conveyor stops; Start → resumes and the
  piece is **correctly sorted**.

## Milestone 3.3 — Sorting station robust
- [ ] 6 pieces (2 black, 2 red, 2 metal) **back-to-back** → all sorted correctly.
- [ ] Branch held → **Q2**, station → Error.
- [ ] Piece taken out before reaching a slide → **Q2**, station → Error.

---

## Milestone L.2 — Line proper
- [ ] Only the **Sorting** Start/Stop/Reset switch the whole line.
- [ ] Reset after setting swivel arm in-between and lift in-between → all home.
- [ ] Process 2 red, 2 metal, 2 black, 2 white through the line.
- [ ] Pause & resume 3×: arm in-between, lift in-between, piece on conveyor.

## Milestone L.3 — Line robust
- [ ] Piece missing from Sorting → **three Q2 lights** on.
- [ ] Safety beam blocked > 3 s → **two Q2 lights** (Testing + Distributing).
- [ ] Swivel arm held → **one Q2 light** (Distributing).
- [ ] All cleared using the **Sorting** buttons only.

---

*Cross-check every box above against the milestone's finite-state diagram whenever
you change the design.*
