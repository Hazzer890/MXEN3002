# FB_Panel — Ladder + ST (Milestone 1.4)

Shared control-panel FB. FSM: `fsm_panel.md`. Milestone 1.4 expects a **ladder
diagram**; the equivalent Structured Text is the canonical source in
`../../usb/st/FB_Panel.st` (identical logic, imported by the PLCopen XML).

## Ladder rung specification

Implemented with four mutually-exclusive latched state bits — `M_PAUSE`, `M_RUN`,
`M_RESET`, `M_ERROR` — set/reset by the transitions. This is the direct ladder
form of the state diagram. `_FirstScan` is the Sysmac first-scan flag.

| # | Rung (contacts in series unless noted) | Action |
|---|---|---|
| 1 | `_FirstScan` | **SET** `M_PAUSE` (power-on default) |
| 2 | `M_PAUSE` · `Panel_S1` · `/error_in` | **SET** `M_RUN`, **RST** `M_PAUSE` |
| 3 | `M_RUN` · `Panel_S2` | **SET** `M_PAUSE`, **RST** `M_RUN` |
| 4 | `M_PAUSE` · `Panel_S4` | **SET** `M_RESET`, **RST** `M_PAUSE` |
| 5 | `M_RESET` · (`Panel_S2` OR `reset_done`) | **SET** `M_PAUSE`, **RST** `M_RESET` |
| 6 | `error_in` | **SET** `M_ERROR`, **RST** `M_PAUSE`, `M_RUN`, `M_RESET` |
| 7 | `M_ERROR` · `Panel_S4` · `/error_in` | **SET** `M_RESET`, **RST** `M_ERROR` |
| 8 | `M_RUN`  → coil | `run_mode`, `start_light` |
| 9 | `M_RESET`→ coil | `reset_mode`, `reset_light` |
| 10 | `M_PAUSE`→ coil | `pause_mode` |
| 11 | `M_ERROR`→ coil | `error_mode` |

Notes for typing this in Sysmac (see Quick-Start Part 2):
- Rung 2's `/error_in` (inverted contact: click contact, press `/`) makes the fault
  win over a simultaneous Start.
- Rung 5's parallel `Panel_S2` OR `reset_done`: place `Panel_S2`, select it, press
  `w` to add the parallel `reset_done` branch.
- SET/RST coils keep the bits latched between scans; rung 6 (error) has priority
  because it resets the other three.

## Equivalent Structured Text (canonical)

```iecst
FUNCTION_BLOCK FB_Panel
VAR_INPUT
    s1_start   : BOOL;   // Panel_S1
    s2_stop    : BOOL;   // Panel_S2
    s4_reset   : BOOL;   // Panel_S4
    error_in   : BOOL;   // latched fault from Main
    reset_done : BOOL;   // all actuators home
END_VAR
VAR_OUTPUT
    run_mode : BOOL; reset_mode : BOOL; pause_mode : BOOL; error_mode : BOOL;
    start_light : BOOL; reset_light : BOOL;
END_VAR
VAR state : INT := 0; END_VAR   // 0 PAUSE 1 RUN 2 RESET 3 ERROR

IF error_in AND state <> 3 THEN
    state := 3;
ELSIF state = 0 THEN
    IF s1_start THEN state := 1; ELSIF s4_reset THEN state := 2; END_IF;
ELSIF state = 1 THEN
    IF s2_stop THEN state := 0; END_IF;
ELSIF state = 2 THEN
    IF s2_stop OR reset_done THEN state := 0; END_IF;
ELSIF state = 3 THEN
    IF s4_reset THEN state := 2; END_IF;
END_IF;

run_mode := (state=1); pause_mode := (state=0);
reset_mode := (state=2); error_mode := (state=3);
start_light := run_mode; reset_light := reset_mode;
END_FUNCTION_BLOCK
```

For the panel-only milestone 1.4, tie `error_in := FALSE` and `reset_done :=
FALSE` at the call site so Reset is exited only by Stop (the invalid-transition
tests then pass exactly).
