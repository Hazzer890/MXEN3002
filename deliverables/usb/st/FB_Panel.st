(*
  FB_Panel  --  shared control-panel FSM for all three Festo stations.
  Implements milestone 1.4.

  States: 0=PAUSE (power-on) 1=RUN 2=RESET 3=ERROR
    PAUSE --S1--> RUN         RUN  --S2--> PAUSE
    PAUSE --S4--> RESET       RESET--S2 or reset_done--> PAUSE
    any --error_in--> ERROR   ERROR--S4--> RESET (error cleared, then homes)
  Invalid transitions (S1 in RESET, S4 in RUN, S1/S2 in ERROR) are ignored.
  Exactly one operational light (start/reset) is ever on.

  reset_done = "all actuators are home" (Main ANDs the FBs' at_home outputs).
  It lets RESET fall back to PAUSE once homing finishes, so error recovery is
  two operator presses (Reset then Start). In the panel-only milestone 1.4 there
  are no actuators, so tie reset_done := FALSE and RESET only exits on S2.
*)
FUNCTION_BLOCK FB_Panel
VAR_INPUT
    s1_start   : BOOL;   // Panel_S1  Start button
    s2_stop    : BOOL;   // Panel_S2  Stop button
    s4_reset   : BOOL;   // Panel_S4  Reset button
    error_in   : BOOL;   // latched fault from actuators / main control block
    reset_done : BOOL;   // TRUE when every actuator reports at_home
END_VAR
VAR_OUTPUT
    run_mode    : BOOL;
    reset_mode  : BOOL;
    pause_mode  : BOOL;
    error_mode  : BOOL;
    start_light : BOOL;  // Station_H1
    reset_light : BOOL;  // Station_H2
END_VAR
VAR
    state : INT := 0;    // 0 PAUSE (power-on default)
END_VAR

IF error_in AND state <> 3 THEN
    state := 3;                          // ERROR forced from any state
ELSIF state = 0 THEN                     // PAUSE
    IF s1_start THEN
        state := 1;
    ELSIF s4_reset THEN
        state := 2;
    END_IF;
ELSIF state = 1 THEN                     // RUN
    IF s2_stop THEN state := 0; END_IF;  // S4 ignored here
ELSIF state = 2 THEN                     // RESET
    IF s2_stop OR reset_done THEN state := 0; END_IF;   // S1 ignored here
ELSIF state = 3 THEN                     // ERROR
    IF s4_reset THEN state := 2; END_IF; // clears fault, begins reset/homing
END_IF;

run_mode    := (state = 1);
pause_mode  := (state = 0);
reset_mode  := (state = 2);
error_mode  := (state = 3);
start_light := run_mode;
reset_light := reset_mode;

END_FUNCTION_BLOCK
