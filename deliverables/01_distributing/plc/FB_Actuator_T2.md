# FB_Actuator_T2 — ST + ladder structure (Milestones 1.7 / 1.8)

Stroke-completing single-acting cylinder (ejection cylinder; reused as the Sorting
branches). FSM: `fsm_T2.md`. Canonical source: `../../usb/st/FB_Actuator_T2.st`.

Same call/structure notes as T1 — an ST state machine with a `TON`. The one
behavioural difference from T1 is that **strokes always finish**: the
`sensor_end`/`sensor_home` transitions ignore pause, so a Stop mid-stroke completes
to a limit and halts there.

## Structured Text (type-in-ready)

```iecst
FUNCTION_BLOCK FB_Actuator_T2
VAR_INPUT
    run_mode : BOOL; pause_mode : BOOL; reset_mode : BOOL; error_mode : BOOL;
    sensor_home : BOOL; sensor_end : BOOL; go : BOOL;
    t_stall : TIME := T#2s; robust : BOOL := FALSE;
END_VAR
VAR_OUTPUT
    at_home : BOOL; to_end : BOOL; at_end : BOOL; to_home : BOOL;
    valve_extend : BOOL; error : BOOL;
END_VAR
VAR state : INT := 0; stall : TON; moving : BOOL; END_VAR

CASE state OF
0:  IF error_mode THEN state := 4;
    ELSIF reset_mode THEN IF NOT sensor_home THEN state := 3; END_IF;
    ELSIF run_mode AND go THEN state := 1; END_IF;
1:  IF error_mode THEN state := 4; ELSIF sensor_end THEN state := 2; END_IF;
2:  IF error_mode THEN state := 4;
    ELSIF reset_mode THEN state := 3;
    ELSIF run_mode THEN state := 3; END_IF;
3:  IF error_mode THEN state := 4; ELSIF sensor_home THEN state := 0; END_IF;
4:  IF reset_mode THEN IF sensor_home THEN state := 0; ELSE state := 3; END_IF; END_IF;
END_CASE;

valve_extend := (state = 1) OR (state = 2);
IF state = 4 THEN valve_extend := FALSE; END_IF;
moving := (state = 1) OR (state = 3);
stall(IN := robust AND moving, PT := t_stall);
IF stall.Q THEN state := 4; valve_extend := FALSE; END_IF;

at_home := (state=0); to_end := (state=1); at_end := (state=2);
to_home := (state=3); error := (state=4);
END_FUNCTION_BLOCK
```

## Call site (Distributing — ejection cylinder)

```iecst
Ejector(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_1B1,  // retracted
    sensor_end  := Station_1B2,  // extended
    go := go_ej,
    t_stall := T#2s,
    robust := FALSE);            // TRUE for milestone 1.8
Station_1Y1 := Ejector.valve_extend;   // Magazine_Eject
```

- **1.7 (proper):** a Stop mid-stroke does not stop the cylinder — it finishes to
  a limit and halts in Pause; resume starts the next stroke.
- **1.8 (robust):** a hold / loss of air beyond `t_stall` → ERROR, valve off.
- The cylinder is held extended at `AT_END` (valve on) so a spring-return cylinder
  can halt fully extended in Pause; it retracts only when run advances to
  `TO_HOME`.
