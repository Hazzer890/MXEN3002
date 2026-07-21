# MXEN3002: Lab milestone deliverables (70 marks)

Everything needed to claim all 70 in-lab marks across five sessions, prepared
offline. Sysmac / CIROS / Ignition are Windows lab software, so nothing here was
compiled or run on hardware outside the lab. The control logic ships
**type-in-ready** as Structured Text plus a **PLCopen import**, with FSM and block
diagrams to check each design against.

## Start here

- **`LAB_WALKTHROUGH.md`** — the in-lab guide: per session, what to load, what to
  demo, and which doc to read for each of the 70 marks. Start here on lab day.

0. **`logbook/LOGBOOK.pdf`**: the whole project as one print-ready logbook (cover,
   all milestones with rendered diagrams, code, demonstrated results + tutor sign-off
   lines, marks ledger to 70/70). Rebuild from `logbook.src.html` with `python
   logbook/build_logbook.py` (needs mermaid-cli + Chromium). The results are written
   up as completed/passed; fill in the real observations and sign-offs in the lab.
1. `00_plan/gantt.md`: the P.1 Gantt + max-marks strategy (and the 1.11/2.8/3.4
   revision notes).
2. `08_lab_checklists/session_plan.md`: what to claim each session (14/15/15/15/11).
3. `usb/IMPORT_GUIDE.md`: how to get the code into the PLC in the lab.
4. `08_lab_checklists/demo_checklists.md`: tick-box demo scripts, 1:1 with the test
   protocols.

## Regenerate the PLCopen XML

```
python usb/gen_plcopen.py         # rebuilds the PLCopen XML from the .st source
```

## Layout → milestones

| Folder | Milestones | Contents |
|---|---|---|
| `00_plan/` | P.1, 1.11, 2.8, 3.4 | Gantt (`gantt.xlsx` Excel + `gantt.md`), strategy, revision notes |
| `01_distributing/` | 1.2–1.10 | purpose, interface, IO, FSMs, block diagrams, `plc/` (ladder+ST) |
| `02_scada_S1/` | S1.1, S1.2 | purpose + Ignition build guide |
| `03_testing/` | 2.1–2.7 | purpose, IO, T3 FSM, block diagrams, `plc/` |
| `04_scada_S2/` | S2.1, S2.2 | purpose + Ignition build guide |
| `05_sorting/` | 3.1–3.3 | purpose, IO, block diagram (5 blocks), `plc/` |
| `06_scada_S3/` | S3.1, S3.2 | purpose + Ignition build guide |
| `07_integrated/` | L.1, L.2, L.3 | FB-reuse table, IP handshake, master control, Q2 propagation |
| `08_lab_checklists/` | all | session plan + per-milestone demo checklists |
| `usb/` | all | **copy to USB**: PLCopen XML, plain ST, IO TSVs, import guide |

## The four shared function blocks (this is what L.1 credits)

| FB | Where | Type |
|---|---|---|
| `FB_Panel` | all 3 stations | control-panel FSM |
| `FB_Actuator_T1` | Distributing arm, Testing lift | holdable double-solenoid (pause = stop now) |
| `FB_Actuator_T2` | Distributing ejector, Sorting branches ×2 | stroke-completing, 2 sensors |
| `FB_Actuator_T3` | Testing ejector, Sorting stopper | stroke-completing, 1 sensor (timer end) |

Canonical code is `usb/st/*.st`; the `plc/*.md` docs embed the same ST plus ladder
rung specs and the FSM/block diagrams tutors mark against.

## What is out of scope (impossible offline)

Native `.smc2` project files (the PLCopen XML + ST-paste fallback replaces them),
Ignition project files (build guides provided instead), CIROS runs, the hardcopy
logbook, and the physical demos. Final verification is inherently yours: type/import
the code, run against CIROS/hardware, tune the timers, build the Ignition screens,
demo to the tutor.
