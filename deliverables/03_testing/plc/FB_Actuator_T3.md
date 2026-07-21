# FB_Actuator_T3 — ST (Milestones 2.4 / 2.5)

Single-sensor stroke-completing cylinder. FSM: `../fsm_T3.md`. Canonical source:
`../../usb/st/FB_Actuator_T3.st`. Reused on the Sorting stopper (L.1).

## Structured Text (type-in-ready)

```iecst
FUNCTION_BLOCK FB_Actuator_T3
VAR_INPUT
    run_mode : BOOL; pause_mode : BOOL; reset_mode : BOOL; error_mode : BOOL;
    sensor_home : BOOL; go : BOOL;
    t_stroke : TIME := T#1s; t_stall : TIME := T#2s; robust : BOOL := FALSE;
END_VAR
VAR_OUTPUT
    at_home : BOOL; to_end : BOOL; at_end : BOOL; to_home : BOOL;
    valve_extend : BOOL; error : BOOL;
END_VAR
VAR state : INT := 0; strokeT : TON; stallT : TON; END_VAR

CASE state OF
0:  IF error_mode THEN state := 4;
    ELSIF reset_mode THEN IF NOT sensor_home THEN state := 3; END_IF;
    ELSIF run_mode AND go THEN state := 1; END_IF;
1:  IF error_mode THEN state := 4; ELSIF strokeT.Q THEN state := 2; END_IF;
2:  IF error_mode THEN state := 4;
    ELSIF reset_mode THEN state := 3;
    ELSIF run_mode THEN state := 3; END_IF;
3:  IF error_mode THEN state := 4; ELSIF sensor_home THEN state := 0; END_IF;
4:  IF reset_mode THEN IF sensor_home THEN state := 0; ELSE state := 3; END_IF; END_IF;
END_CASE;

valve_extend := (state = 1) OR (state = 2);
IF state = 4 THEN valve_extend := FALSE; END_IF;
strokeT(IN := (state = 1), PT := t_stroke);
stallT (IN := robust AND (state = 3), PT := t_stall);
IF stallT.Q THEN state := 4; valve_extend := FALSE; END_IF;

at_home := (state=0); to_end := (state=1); at_end := (state=2);
to_home := (state=3); error := (state=4);
END_FUNCTION_BLOCK
```

## Call site (Testing — ejecting cylinder)

```iecst
Ejector(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_2B1,   // retracted (the only sensor)
    go := go_ej,
    t_stroke := T#1s,             // tune: just longer than real extend travel
    t_stall  := T#2s,
    robust := FALSE);             // TRUE for milestone 2.5
Station_2Y1 := Ejector.valve_extend;   // Advance Ejecting Cylinder
```

Note: `t_stroke` covers the unsensed extend; `t_stall` catches a held retract.
See `../fsm_T3.md` for why extend-stall is undetectable with one sensor.
