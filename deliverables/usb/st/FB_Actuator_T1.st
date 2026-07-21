(*
  FB_Actuator_T1  --  holdable double-solenoid actuator.
  Used for: Distributing swivel arm, Testing lift.

  Holdable = pause STOPS IT IMMEDIATELY mid-stroke (both valves off traps it in
  place); resume continues to the SAME target (no jerk home). Reset drives it
  directly home, aborting any stroke. Robust variant: a TON stall timer -- moving
  with the target sensor not reached within t_stall -- forces ERROR.

  States: 0 AT_HOME 1 TO_END 2 AT_END 3 TO_HOME 4 ERROR
  Milestone 1.5/1.6 (arm), 2.2/2.3 (lift). t_stall is an INPUT: tune in the lab.

  NOTE (milestone 1.9): this FB must NOT contain Station_2Y1/2Y2 (vacuum /
  ejector pulse). It drives only its own two solenoids. Vacuum lives in Main.
*)
FUNCTION_BLOCK FB_Actuator_T1
VAR_INPUT
    run_mode    : BOOL;
    pause_mode  : BOOL;
    reset_mode  : BOOL;
    error_mode  : BOOL;
    sensor_home : BOOL;          // at-home limit switch
    sensor_end  : BOOL;          // at-end  limit switch
    go          : BOOL;          // Main requests a stroke (hold TRUE = continuous)
    t_stall     : TIME := T#2s;  // stall timeout (lab-tunable)
    robust      : BOOL := FALSE; // TRUE enables stall detection (1.6 / 2.3)
END_VAR
VAR_OUTPUT
    at_home      : BOOL;
    to_end       : BOOL;
    at_end       : BOOL;
    to_home      : BOOL;
    valve_to_end : BOOL;         // Station_3Y2 (arm) / Station_1Y2 (lift up)
    valve_to_home: BOOL;         // Station_3Y1 (arm) / Station_1Y1 (lift down)
    error        : BOOL;
END_VAR
VAR
    state  : INT := 0;
    stall  : TON;
    moving : BOOL;
END_VAR

CASE state OF
0:  (* AT_HOME *)
    IF error_mode THEN state := 4;
    ELSIF reset_mode THEN
        IF NOT sensor_home THEN state := 3; END_IF;
    ELSIF run_mode AND go THEN
        state := 1;
    END_IF;
1:  (* TO_END *)
    IF error_mode THEN state := 4;
    ELSIF reset_mode THEN state := 3;          // abort stroke, go home
    ELSIF pause_mode THEN ;                     // freeze in place
    ELSIF sensor_end THEN state := 2;
    END_IF;
2:  (* AT_END *)
    IF error_mode THEN state := 4;
    ELSIF reset_mode THEN state := 3;
    ELSIF run_mode AND go THEN state := 3;      // continuous cycle
    END_IF;
3:  (* TO_HOME *)
    IF error_mode THEN state := 4;
    ELSIF pause_mode AND NOT reset_mode THEN ;  // freeze (reset overrides pause)
    ELSIF sensor_home THEN state := 0;
    END_IF;
4:  (* ERROR -- valves off, recover only via reset sequence *)
    IF reset_mode THEN
        IF sensor_home THEN state := 0; ELSE state := 3; END_IF;
    END_IF;
END_CASE;

// Valves derive from the final state; pause zeroes them (hold in place).
valve_to_end  := (state = 1) AND NOT pause_mode;
valve_to_home := (state = 3) AND NOT pause_mode;

// Stall detection: commanding a valve but not arriving.
moving := valve_to_end OR valve_to_home;
stall(IN := robust AND moving, PT := t_stall);
IF stall.Q THEN state := 4; END_IF;

IF state = 4 THEN
    valve_to_end := FALSE;
    valve_to_home := FALSE;
END_IF;

at_home := (state = 0);
to_end  := (state = 1);
at_end  := (state = 2);
to_home := (state = 3);
error   := (state = 4);

END_FUNCTION_BLOCK
