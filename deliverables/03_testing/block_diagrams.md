# Testing Station — Block Diagrams (2.2 → 2.4 → 2.6)

Grows the same way as Station 1. The lift block is `FB_Actuator_T1` **reused** from
the Distributing station (L.1 credit); the ejector is the new `FB_Actuator_T3`.

## 2-block — Milestone 2.2 (lift only)

```mermaid
flowchart LR
    BTN[Panel_S1/S2/S4] --> PANEL[FB_Panel]
    PANEL -- mode bits --> LIFT[FB_Actuator_T1<br/>lift = REUSED]
    B1U[Station_1B1 up] --> LIFT
    B1D[Station_1B2 down] --> LIFT
    LIFT -- valve_to_home --> Y1[Station_1Y1 down]
    LIFT -- valve_to_end --> Y2[Station_1Y2 up]
    LIFT -- at_home --> PANEL
```

## 3-block — Milestone 2.4 (add ejecting cylinder T3)

```mermaid
flowchart LR
    BTN --> PANEL[FB_Panel]
    PANEL --> LIFT[FB_Actuator_T1<br/>lift]
    PANEL --> EJ[FB_Actuator_T3<br/>ejector, 1 sensor]
    LIFT --> Y12[1Y1/1Y2]
    EJ -- valve_extend --> Y21[Station_2Y1]
    B2B1[Station_2B1 retracted] --> EJ
```

## 4-block — Milestone 2.6 / 2.7 (full station)

```mermaid
flowchart TB
    BTN[Panel_S1/S2/S4] --> PANEL[FB_Panel]
    PANEL -- mode bits --> MAIN[Main control block]
    PANEL -- mode bits --> LIFT[FB_Actuator_T1<br/>lift]
    PANEL -- mode bits --> EJ[FB_Actuator_T3<br/>ejector]
    MAIN -- go_lift --> LIFT
    MAIN -- go_ej --> EJ
    LIFT -- at_home/at_end/error --> MAIN
    EJ -- at_home/at_end/error --> MAIN
    MAIN -- error_in --> PANEL
    MAIN -- reset_done --> PANEL
    PARTAV[Part_AV] --> MAIN
    B2[Station_B2 not-black] --> MAIN
    B5[Station_B5 height] --> MAIN
    B4[Station_B4 safety beam] --> MAIN
    LIFT --> Y12[1Y1/1Y2]
    EJ --> Y21[2Y1]
    MAIN -- blower --> Y31[Station_3Y1]
    MAIN -- Q1 slide full --> H3[Station_H3]
    PANEL -- Q2 --> H4[Station_H4]
```

**The four blocks:** `FB_Panel`, `FB_Actuator_T1` (lift, reused),
`FB_Actuator_T3` (ejector), **Main**. Main owns the colour/height sort decision,
the blower, the top/bottom slide counters, the safety-beam interlock and Q1/Q2 —
i.e. every sensor/valve not belonging to an actuator FB (`Part_AV`, `B2`, `B5`,
`B4`, `3Y1`), which is the "unused sensors/valves in a block" 2.6 requires.

For 2.7 (robust) the diagram is unchanged; the actuator FBs get `robust := TRUE`
and Main adds the slide-full and beam faults to `error_in`.

## Main sequence FSM (per-piece, milestone 2.6)

```mermaid
stateDiagram-v2
    [*] --> IDLE
    IDLE --> EJECT_BOTTOM : Part_AV & black
    IDLE --> LIFTING      : Part_AV & not black
    LIFTING --> HEIGHT    : lift up (beam clear)
    HEIGHT --> EJECT_TOP  : tall (red/metal), top slide not full
    HEIGHT --> LOWER      : white -> bottom (or top full)
    EJECT_TOP --> LOWER   : ejected, top++, blower 1 s
    LOWER --> EJECT_BOTTOM : lift home & piece routes bottom
    LOWER --> IDLE        : lift home & top-slide piece done
    EJECT_BOTTOM --> IDLE : ejected, bottom++
```

- **White / black → bottom slide; red/metal → top slide** (blower on ~1 s during
  the top-slide transfer).
- **Black never lifts** (goes straight to `EJECT_BOTTOM`).
- **2.7 robust:** if a white piece meets a **full** bottom slide it stops at entry
  and Q2 fires (reset required); a non-white piece with the bottom full still goes
  to the top slide (station stays in Run); Q1 lights when the bottom slide reaches
  5. Beam blocked > 3 s → Q2. Lift held > `t_stall` → Q2.
