(*  Test_Lift  --  Milestones 2.2 / 2.3: testing lift alone (FB_Actuator_T1 reused).
    Testing I/O. home = down (1B2/1Y1), end = up (1B1/1Y2). Switch off the air
    mid-travel to trigger the 2.3 stall. FSM: 01_distributing/fsm_T1.md
*)
PROGRAM Test_Lift
VAR Panel : FB_Panel; Lift : FB_Actuator_T1; ROBUST : BOOL := FALSE; END_VAR

Panel(s1_start := Panel_S1, s2_stop := NOT Panel_S2, (* Stop wired NC *) s4_reset := Panel_S4,
      error_in := ROBUST AND Lift.error, reset_done := Lift.at_home);
Lift(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_1B2, sensor_end := Station_1B1,
    go := Panel.run_mode, t_stall := T#2s, robust := ROBUST);

Station_1Y1 := Lift.valve_to_home;  // Lift Down
Station_1Y2 := Lift.valve_to_end;   // Lift Up
Station_H1  := Panel.start_light;
Station_H2  := Panel.reset_light;
Station_H4  := Panel.error_mode;    // Q2 (testing lights are Station_H1..H4)
END_PROGRAM
