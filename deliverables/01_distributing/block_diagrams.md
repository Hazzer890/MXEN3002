# Distributing Station — Block Diagrams (1.5 → 1.7 → 1.9)

Block diagrams grow one block at a time across the milestones. Each shows how the
control-panel mode bits fan out to the actuator FBs, and how sensor inputs and
valve outputs wire to each block. All arrows are BOOL signals.

## 2-block version — Milestone 1.5 (arm only)

```mermaid
flowchart LR
    BTN[Panel_S1/S2/S4] --> PANEL[FB_Panel]
    PANEL -- run/pause/reset/error --> ARM[FB_Actuator_T1<br/>swivel arm]
    S3S1[Station_3S1 home] --> ARM
    S3S2[Station_3S2 end] --> ARM
    ARM -- valve_to_home --> Y3Y1[Station_3Y1]
    ARM -- valve_to_end --> Y3Y2[Station_3Y2]
    PANEL -- start_light --> H1[Station_H1]
    PANEL -- reset_light --> H2[Station_H2]
    ARM -- at_home --> PANEL
```

`FB_Panel` outputs the mode; `FB_Actuator_T1` reads the mode + its two limit
switches and drives its two solenoids. The arm's `at_home` feeds back as the
panel's `reset_done`.

## 3-block version — Milestone 1.7 (add ejection cylinder)

```mermaid
flowchart LR
    BTN[Panel_S1/S2/S4] --> PANEL[FB_Panel]
    PANEL --> ARM[FB_Actuator_T1<br/>swivel arm]
    PANEL --> EJ[FB_Actuator_T2<br/>ejection cylinder]
    S3[3S1/3S2] --> ARM
    S1[1B1/1B2] --> EJ
    ARM --> Y3[3Y1/3Y2]
    EJ -- valve_extend --> Y1[Station_1Y1]
    PANEL --> LIGHTS[H1/H2]
```

## 4-block version — Milestone 1.9 (full station)

```mermaid
flowchart TB
    BTN[Panel_S1/S2/S4] --> PANEL[FB_Panel]
    PANEL -- mode bits --> MAIN[Main control block]
    PANEL -- mode bits --> ARM[FB_Actuator_T1<br/>arm]
    PANEL -- mode bits --> EJ[FB_Actuator_T2<br/>ejector]
    MAIN -- go_arm --> ARM
    MAIN -- go_ej --> EJ
    ARM -- at_home/at_end --> MAIN
    EJ -- at_home/at_end --> MAIN
    ARM & EJ -- error --> MAIN
    MAIN -- error_in --> PANEL
    MAIN -- reset_done --> PANEL
    ARM --> Y3[3Y1/3Y2]
    EJ --> Y1[1Y1]
    MAIN -- vacuum --> Y2A[Station_2Y1]
    MAIN -- eject pulse --> Y2B[Station_2Y2]
    MAIN -- Q1 --> H3[Panel_H3]
    PANEL -- Q2 --> H4[Panel_H4]
    B4[Station_B4 mag empty] --> MAIN
    IPFI[IP_FI] --> MAIN
```

**The four blocks are:** `FB_Panel`, `FB_Actuator_T1`, `FB_Actuator_T2`, and
**Main**. Design rules the milestone enforces, all satisfied here:

- **`Station_2Y1` (vacuum) and `Station_2Y2` (ejector pulse) live in Main**, never
  in `FB_Actuator_T1`.
- **The unused sensors/valves** (`Station_B4` magazine-empty, `IP_FI`) are wired
  into **Main**, the "main control block".
- Main runs the **7-step cycle sequencer** and the **5-piece batch counter**, and
  aggregates the actuator faults into the panel's `error_in`.

For milestone 1.10 (robust) the block diagram is unchanged — the same four blocks,
with the actuator FBs' `robust` input set TRUE and Main forwarding their `error`
plus the piece-missing / magazine-empty checks to `FB_Panel`.
