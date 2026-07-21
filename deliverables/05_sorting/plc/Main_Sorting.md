# Main_Sorting — ST (Milestones 3.1 / 3.2)

The 5th block: conveyor, sort decision, slide counters, slide-full interlock,
Q1/Q2. Reuses `FB_Panel`, `FB_Actuator_T2` (×2, branches), `FB_Actuator_T3`
(stopper). Sequence FSM: `../block_diagrams.md`. Canonical source:
`../../usb/st/Main_Sorting.st`.

## Structured Text (type-in-ready)

```iecst
PROGRAM Main_Sorting
VAR
    Panel : FB_Panel; Branch1 : FB_Actuator_T2; Branch2 : FB_Actuator_T2;
    Stopper : FB_Actuator_T3;
    pos : INT := 0; dest : INT := 0; have : BOOL;
    s1c, s2c, s3c : INT := 0;
    conveyor, go_b1, go_b2, go_stop, metal, red, black, slide_full : BOOL;
    fault, reset_done : BOOL;
    ROBUST : BOOL := TRUE; CAP : INT := 5;
END_VAR

reset_done := Branch1.at_home AND Branch2.at_home;
Panel(s1_start := Panel_S1, s2_stop := Panel_S2, s4_reset := Panel_S4,
      error_in := fault, reset_done := reset_done);

IF Panel.reset_mode OR Panel.error_mode THEN have := FALSE; pos := 0; END_IF;

slide_full := Station_B4 OR (s1c >= CAP) OR (s2c >= CAP) OR (s3c >= CAP);

conveyor := FALSE; go_b1 := FALSE; go_b2 := FALSE; go_stop := FALSE;
IF Panel.run_mode AND NOT slide_full THEN
    IF NOT have THEN
        IF Part_AV THEN
            metal := Station_B2; black := NOT Station_B3;
            red := Station_B3 AND NOT Station_B2;
            IF metal THEN dest := 0; ELSIF red THEN dest := 1; ELSE dest := 2; END_IF;
            have := TRUE; pos := 0; go_stop := TRUE;
        END_IF;
    ELSE
        CASE dest OF
        0:  IF pos < 1 THEN conveyor := TRUE; pos := pos+1;
            ELSE go_b1 := TRUE;
                IF Branch1.at_end THEN s1c := s1c+1; have := FALSE; END_IF;
            END_IF;
        1:  IF pos < 2 THEN conveyor := TRUE; pos := pos+1;
            ELSE go_b2 := TRUE;
                IF Branch2.at_end THEN s2c := s2c+1; have := FALSE; END_IF;
            END_IF;
        2:  IF pos < 3 THEN conveyor := TRUE; pos := pos+1;
            ELSE s3c := s3c+1; have := FALSE; END_IF;
        END_CASE;
    END_IF;
END_IF;

Branch1(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_1B1, sensor_end := Station_1B2, go := go_b1,
    t_stall := T#2s, robust := ROBUST);
Branch2(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_2B1, sensor_end := Station_2B2, go := go_b2,
    t_stall := T#2s, robust := ROBUST);
Stopper(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := TRUE, go := go_stop,
    t_stroke := T#1s, t_stall := T#2s, robust := ROBUST);

fault := (ROBUST AND (Branch1.error OR Branch2.error))
    OR (Panel.run_mode AND slide_full)
    OR (ROBUST AND Panel.run_mode AND have AND pos >= 1 AND NOT Part_AV);

Station_K1  := conveyor AND NOT Panel.error_mode;
Station_1Y1 := Branch1.valve_extend;   Station_2Y1 := Branch2.valve_extend;
Station_3Y1 := Stopper.valve_extend;
Station_H1  := Panel.start_light;      Station_H2 := Panel.reset_light;
Station_H3  := slide_full;             Station_H4 := Panel.error_mode;
IP_N_FO     := Panel.run_mode;
END_PROGRAM
```

## Proper vs robust + protocol mapping

- **3.1 (proper, `ROBUST := FALSE`):** 2 red, 2 metal, 2 black sort to slides 2, 1,
  3 respectively. **Any slide full → Q1 on and station → Error** (test 3.1.2 —
  `slide_full` forces `fault` even when `ROBUST` is FALSE, because Q1+Error there is
  a proper-mode requirement). Reset homes all actuators; pause completes a branch
  stroke to its limit then halts, conveyor stops/resumes.
- **3.2 (robust, `ROBUST := TRUE`):** 6 back-to-back pieces sort correctly; a
  **branch held** → Q2 (T2 stall); a **piece removed before a slide** → Q2
  (`have & pos>=1 & NOT Part_AV`). **Verify the `Part_AV` / removal behaviour on
  the bench** and adjust that condition if the sensor reports differently.

Counters `s1c/s2c/s3c` and `Station_B4` both feed `slide_full`; each slide holds 5.
Timers are lab-tunable FB inputs.
