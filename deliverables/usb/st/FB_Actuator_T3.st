(*
  FB_Actuator_T3  --  stroke-completing single-acting cylinder, ONE limit sensor.
  Used for: Testing ejection cylinder (only a retracted switch, Station_2B1).

  Same contract as T2 but the EXTENDED end has no switch: it is inferred from a
  stroke timer (t_stroke). Because there is no extend sensor, stall is only
  detectable on the RETRACT leg (t_stall on failing to reach sensor_home). A
  cylinder held while extended is caught on the following retract attempt.
  Set t_stroke slightly longer than the real extend travel; tune in the lab.

  States: 0 AT_HOME 1 TO_END(timer) 2 AT_END 3 TO_HOME(sensor) 4 ERROR
  Milestone 2.4/2.5. Reused on Sorting stopper (single-sensor) per L.1.
*)
FUNCTION_BLOCK FB_Actuator_T3
VAR_INPUT
    run_mode    : BOOL;
    pause_mode  : BOOL;
    reset_mode  : BOOL;
    error_mode  : BOOL;
    sensor_home : BOOL;          // retracted limit switch (the only one)
    go          : BOOL;
    t_stroke    : TIME := T#1s;  // assumed extend time (no end sensor)
    t_stall     : TIME := T#2s;  // retract stall timeout
    robust      : BOOL := FALSE;
END_VAR
VAR_OUTPUT
    at_home      : BOOL;
    to_end       : BOOL;
    at_end       : BOOL;
    to_home      : BOOL;
    valve_extend : BOOL;
    error        : BOOL;
END_VAR
VAR
    state  : INT := 0;
    strokeT: TON;
    stallT : TON;
END_VAR

CASE state OF
0:  (* AT_HOME *)
    IF error_mode THEN state := 4;
    ELSIF reset_mode THEN
        IF NOT sensor_home THEN state := 3; END_IF;
    ELSIF run_mode AND go THEN state := 1;
    END_IF;
1:  (* TO_END -- no sensor, trust the stroke timer *)
    IF error_mode THEN state := 4;
    ELSIF strokeT.Q THEN state := 2;
    END_IF;
2:  (* AT_END *)
    IF error_mode THEN state := 4;
    ELSIF reset_mode THEN state := 3;
    ELSIF run_mode THEN state := 3;
    END_IF;
3:  (* TO_HOME -- retract, sensor_home ends it *)
    IF error_mode THEN state := 4;
    ELSIF sensor_home THEN state := 0;
    END_IF;
4:  (* ERROR *)
    IF reset_mode THEN
        IF sensor_home THEN state := 0; ELSE state := 3; END_IF;
    END_IF;
END_CASE;

valve_extend := (state = 1) OR (state = 2);
IF state = 4 THEN valve_extend := FALSE; END_IF;

strokeT(IN := (state = 1), PT := t_stroke);
stallT (IN := robust AND (state = 3), PT := t_stall);   // retract-only stall
IF stallT.Q THEN
    state := 4;
    valve_extend := FALSE;
END_IF;

at_home := (state = 0);
to_end  := (state = 1);
at_end  := (state = 2);
to_home := (state = 3);
error   := (state = 4);

END_FUNCTION_BLOCK
