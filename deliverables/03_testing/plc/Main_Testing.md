# Main_Testing — ST (Milestones 2.6 / 2.7)

The 4th block: colour/height sort, blower, slide counters, safety-beam interlock,
Q1/Q2, fault aggregation. Reuses `FB_Panel` and `FB_Actuator_T1` (lift) unchanged.
Sequence FSM: `../block_diagrams.md`. Canonical source:
`../../usb/st/Main_Testing.st`.

## Sort logic (from sensors)

| Piece | `Station_B2` (not-black) | `Station_B5` (tall) | Route |
|---|---|---|---|
| Black | 0 | – | Bottom slide, **no lift** |
| White | 1 | 0 (short) | Bottom slide (after lift + height check) |
| Red / metal | 1 | 1 (tall) | **Top slide**, blower ~1 s |

## Structured Text (type-in-ready)

```iecst
PROGRAM Main_Testing
VAR
    Panel : FB_Panel; Lift : FB_Actuator_T1; Ejector : FB_Actuator_T3;
    ps : INT := 0; dest_bottom : BOOL; bottom, top : INT := 0; beam_ctr : INT := 0;
    go_lift, go_ej, blower, black, tall, beam_blocked : BOOL;
    fault, reset_done, beam_fault, proc_fault : BOOL;
    ROBUST : BOOL := TRUE; CAP : INT := 5; BEAM_LIMIT : INT := 3;
END_VAR

reset_done := Lift.at_home AND Ejector.at_home;
Panel(s1_start := Panel_S1, s2_stop := Panel_S2, s4_reset := Panel_S4,
      error_in := fault, reset_done := reset_done);

IF Panel.reset_mode OR Panel.error_mode THEN
    ps := 0; beam_ctr := 0; proc_fault := FALSE; dest_bottom := FALSE;
END_IF;

beam_blocked := NOT Station_B4;      // through-beam TRUE=clear; verify on bench
beam_fault := FALSE;
IF beam_blocked AND (ps = 1 OR ps = 5) THEN
    beam_ctr := beam_ctr + 1;
    IF ROBUST AND beam_ctr >= BEAM_LIMIT THEN beam_fault := TRUE; END_IF;
ELSIF NOT beam_blocked THEN beam_ctr := 0; END_IF;

go_lift := FALSE; go_ej := FALSE; blower := FALSE;
IF Panel.run_mode THEN
    CASE ps OF
    0:  IF Part_AV THEN
            black := NOT Station_B2;
            IF black THEN ps := 4; ELSE ps := 1; END_IF;
        END_IF;
    1:  IF NOT beam_blocked THEN
            go_lift := TRUE; IF Lift.at_end THEN ps := 2; END_IF;
        END_IF;
    2:  tall := Station_B5;
        IF tall THEN
            IF top < CAP THEN ps := 3; ELSE ps := 5; dest_bottom := FALSE; END_IF;
        ELSE
            IF ROBUST AND bottom >= CAP THEN proc_fault := TRUE;
            ELSE dest_bottom := TRUE; ps := 5; END_IF;
        END_IF;
    3:  go_ej := TRUE; blower := TRUE;
        IF Ejector.at_end THEN top := top+1; dest_bottom := FALSE; ps := 5; END_IF;
    4:  go_ej := TRUE;
        IF Ejector.at_end THEN bottom := bottom+1; ps := 0; END_IF;
    5:  go_lift := TRUE;
        IF Lift.at_home THEN
            IF dest_bottom THEN ps := 4; ELSE ps := 0; END_IF;
        END_IF;
    END_CASE;
END_IF;

Lift(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_1B2, sensor_end := Station_1B1, go := go_lift,
    t_stall := T#2s, robust := ROBUST);
Ejector(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_2B1, go := go_ej,
    t_stroke := T#1s, t_stall := T#2s, robust := ROBUST);

fault := ROBUST AND (Lift.error OR Ejector.error OR beam_fault OR proc_fault);

Station_1Y1 := Lift.valve_to_home;   Station_1Y2 := Lift.valve_to_end;
Station_2Y1 := Ejector.valve_extend;
Station_3Y1 := blower AND NOT Panel.error_mode;
Station_H1 := Panel.start_light;     Station_H2 := Panel.reset_light;
Station_H3 := (bottom >= CAP);       Station_H4 := Panel.error_mode;
IP_N_FO := Panel.run_mode;
END_PROGRAM
```

## Proper vs robust + protocol mapping

- **2.6 (proper, `ROBUST := FALSE`):** 3 white → bottom, 3 red/metal → top with
  blower, 3 black → bottom without lifting. Pause freezes the lift mid-travel
  (T1), resume continues; reset homes lift and retracts ejector.
- **2.7 (robust, `ROBUST := TRUE`):**
  - **Bottom slide full** (3 black + 2 white = 5) → **Q1 on**.
  - **White + bottom full** → stops at entry, **Q2**, reset required
    (`proc_fault`).
  - **Non-white + bottom full** → still routes to top slide, stays in Run.
  - **Lift held > `t_stall`** → Q2 (T1 stall).
  - **Safety beam blocked > `BEAM_LIMIT` scans (~3 s)** → Q2; while blocked during
    a lift move the lift is held stationary.

`BEAM_LIMIT` and the timers are lab-tunable. **Confirm the `Station_B4` beam
polarity** on the bench — flip the `beam_blocked := NOT Station_B4` line if the
interlock reads inverted.
