# Sorting Station — Block Diagram (5 blocks, Milestone 3.2)

Milestone 3.2 asks for a **5-block** diagram. The two branches and the stopper are
reused actuator FBs; Main owns the conveyor, recognition and counters.

```mermaid
flowchart TB
    BTN[Panel_S1/S2/S4] --> PANEL[FB_Panel]
    PANEL -- mode bits --> MAIN[Main control block]
    PANEL -- mode bits --> B1[FB_Actuator_T2<br/>branch 1]
    PANEL -- mode bits --> B2[FB_Actuator_T2<br/>branch 2]
    PANEL -- mode bits --> STOP[FB_Actuator_T3<br/>stopper]
    MAIN -- go_b1 --> B1
    MAIN -- go_b2 --> B2
    MAIN -- go_stop --> STOP
    B1 -- at_end/error --> MAIN
    B2 -- at_end/error --> MAIN
    MAIN -- error_in --> PANEL
    MAIN -- reset_done --> PANEL
    PARTAV[Part_AV] --> MAIN
    MB2[Station_B2 metal] --> MAIN
    MB3[Station_B3 not-black] --> MAIN
    MB4[Station_B4 slide full] --> MAIN
    B1 --> Y11[Station_1Y1]
    B2 --> Y21[Station_2Y1]
    STOP --> Y31[Station_3Y1]
    MAIN -- conveyor --> K1[Station_K1]
    MAIN -- Q1 slide full --> H3[Station_H3]
    PANEL -- Q2 --> H4[Station_H4]
```

**The five blocks:** `FB_Panel`, `FB_Actuator_T2` (branch 1), `FB_Actuator_T2`
(branch 2), `FB_Actuator_T3` (stopper), **Main**. Main owns the conveyor
(`Station_K1`), the recognition sensors (`B2`/`B3`), the slide-full interlock
(`B4`), the three slide counters, and Q1/Q2 — the "unused sensors/valves in a
block" 3.2 requires.

## Sort sequence FSM (per piece)

```mermaid
stateDiagram-v2
    [*] --> WAIT
    WAIT --> CLASSIFY : Part_AV (pulse stopper)
    CLASSIFY --> TO_B1 : metal
    CLASSIFY --> TO_B2 : red (not metal, not black)
    CLASSIFY --> TO_END : black
    TO_B1 --> DONE : conveyor to branch1, branch1 extend, at_end -> slide1++
    TO_B2 --> DONE : conveyor to branch2, branch2 extend, at_end -> slide2++
    TO_END --> DONE : conveyor to end -> slide3++
    DONE --> WAIT : next piece
```

- **Metal → branch 1 / slide 1; red → branch 2 / slide 2; black → straight /
  slide 3.**
- **Any slide full** (`Station_B4` or a counter at 5) → **Q1 on and the station
  changes to Error** (test 3.1.2) — Q1 and Q2 both light.
- **3.2 robust:** 6 back-to-back pieces (2 black, 2 red, 2 metal) sort correctly;
  a **branch held** → Q2 (T2 stall); a **piece removed** before reaching a slide →
  Q2. Diagram unchanged; branches get `robust := TRUE`.
- **Pause:** a branch mid-stroke **completes to its limit** then halts (T2); the
  conveyor stops on Stop and resumes on Start, re-sorting the piece correctly.
