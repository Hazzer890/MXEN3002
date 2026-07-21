(*
  FB_Actuator_T2  --  stroke-completing single-acting cylinder, TWO limit sensors.
  Used for: Distributing ejection cylinder, Sorting branch 1 & branch 2.

  Stroke-completing = pause takes effect ONLY at end of stroke. If Stop is pressed
  mid-travel the cylinder finishes to the limit (extended or retracted) and halts
  there; it never stops mid-stroke. Single solenoid: valve ON = extend, valve OFF =
  spring retract. To halt extended in pause the valve is HELD on at AT_END.

  States: 0 AT_HOME(retracted) 1 TO_END(extend) 2 AT_END(extended) 3 TO_HOME(retract) 4 ERROR
  Milestone 1.7/1.8 (ejector), used again on Sorting branches (L.1). t_stall lab-tunable.
*)
FUNCTION_BLOCK FB_Actuator_T2
VAR_INPUT
    run_mode    : BOOL;
    pause_mode  : BOOL;
    reset_mode  : BOOL;
    error_mode  : BOOL;
    sensor_home : BOOL;          // retracted limit switch
    sensor_end  : BOOL;          // extended limit switch
    go          : BOOL;
    t_stall     : TIME := T#2s;
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
    stall  : TON;
    moving : BOOL;
END_VAR

CASE state OF
0:  (* AT_HOME *)
    IF error_mode THEN state := 4;
    ELSIF reset_mode THEN
        IF NOT sensor_home THEN state := 3; END_IF;
    ELSIF run_mode AND go THEN state := 1;
    END_IF;
1:  (* TO_END -- stroke completes regardless of pause *)
    IF error_mode THEN state := 4;
    ELSIF sensor_end THEN state := 2;
    END_IF;
2:  (* AT_END -- valve held extended; only run advances to retract *)
    IF error_mode THEN state := 4;
    ELSIF reset_mode THEN state := 3;
    ELSIF run_mode THEN state := 3;
    END_IF;
3:  (* TO_HOME -- valve off, spring retracts, completes regardless of pause *)
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

moving := (state = 1) OR (state = 3);
stall(IN := robust AND moving, PT := t_stall);
IF stall.Q THEN
    state := 4;
    valve_extend := FALSE;
END_IF;

at_home := (state = 0);
to_end  := (state = 1);
at_end  := (state = 2);
to_home := (state = 3);
error   := (state = 4);

END_FUNCTION_BLOCK
