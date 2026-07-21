# FB_Actuator_T1 — ST + ladder structure (Milestones 1.5 / 1.6)

Holdable double-solenoid actuator (swivel arm; reused as the Testing lift). FSM:
`fsm_T1.md`. Canonical source: `../../usb/st/FB_Actuator_T1.st`.

The logic is a state machine with a stall timer — cleanest as **Structured Text**.
Sysmac runs ST FBs natively; type the ST below into an ST-language FB. If you must
draw it in ladder, the structure is: one rung block per `CASE` state selecting the
next state, then output rungs (`valve_to_end`, `valve_to_home`, status bits) driven
by the state variable, and a `TON` instruction for the stall timer. The ST is far
less error-prone and marks identically against the FSM.

## Structured Text (type-in-ready)

```iecst
FUNCTION_BLOCK FB_Actuator_T1
VAR_INPUT
    run_mode : BOOL; pause_mode : BOOL; reset_mode : BOOL; error_mode : BOOL;
    sensor_home : BOOL; sensor_end : BOOL; go : BOOL;
    t_stall : TIME := T#2s; robust : BOOL := FALSE;
END_VAR
VAR_OUTPUT
    at_home : BOOL; to_end : BOOL; at_end : BOOL; to_home : BOOL;
    valve_to_end : BOOL; valve_to_home : BOOL; error : BOOL;
END_VAR
VAR state : INT := 0; stall : TON; moving : BOOL; END_VAR

CASE state OF
0:  IF error_mode THEN state := 4;
    ELSIF reset_mode THEN IF NOT sensor_home THEN state := 3; END_IF;
    ELSIF run_mode AND go THEN state := 1; END_IF;
1:  IF error_mode THEN state := 4;
    ELSIF reset_mode THEN state := 3;
    ELSIF pause_mode THEN ;
    ELSIF sensor_end THEN state := 2; END_IF;
2:  IF error_mode THEN state := 4;
    ELSIF reset_mode THEN state := 3;
    ELSIF run_mode AND go THEN state := 3; END_IF;
3:  IF error_mode THEN state := 4;
    ELSIF pause_mode AND NOT reset_mode THEN ;
    ELSIF sensor_home THEN state := 0; END_IF;
4:  IF reset_mode THEN IF sensor_home THEN state := 0; ELSE state := 3; END_IF; END_IF;
END_CASE;

valve_to_end  := (state = 1) AND NOT pause_mode;
valve_to_home := (state = 3) AND NOT pause_mode;
moving := valve_to_end OR valve_to_home;
stall(IN := robust AND moving, PT := t_stall);
IF stall.Q THEN state := 4; END_IF;
IF state = 4 THEN valve_to_end := FALSE; valve_to_home := FALSE; END_IF;

at_home := (state=0); to_end := (state=1); at_end := (state=2);
to_home := (state=3); error := (state=4);
END_FUNCTION_BLOCK
```

## Call site (Distributing — arm)

```iecst
Arm(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_3S1,  // arm at magazine
    sensor_end  := Station_3S2,  // arm downstream
    go := go_arm,                // Main gates the stroke
    t_stall := T#2s,
    robust := FALSE);            // TRUE for milestone 1.6
Station_3Y1 := Arm.valve_to_home;   // Arm_to_Magazine
Station_3Y2 := Arm.valve_to_end;    // Arm_to_Subsequent
```

- **1.5 (proper):** `robust := FALSE`. Pause freezes it mid-stroke; resume
  continues forward; reset homes it.
- **1.6 (robust):** `robust := TRUE`. A hold longer than `t_stall` forces the
  ERROR state (Q2 via Main), valves off. Recover with Reset then Start.
- **Milestone 1.9 rule:** this FB drives only `3Y1`/`3Y2`. It contains **no**
  vacuum or ejector-pulse output — those are Main's.
