(*  Test_Arm  --  Milestones 1.5 (ROBUST FALSE) / 1.6 (ROBUST TRUE): swivel arm alone.
    Distributing I/O. go := run so the arm cycles magazine<->downstream continuously.
    FSM: 01_distributing/fsm_T1.md
*)
PROGRAM Test_Arm
VAR Panel : FB_Panel; Arm : FB_Actuator_T1; ROBUST : BOOL := FALSE; END_VAR

Panel(s1_start := Panel_S1, s2_stop := Panel_S2, s4_reset := Panel_S4,
      error_in := ROBUST AND Arm.error, reset_done := Arm.at_home);
Arm(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_3S1, sensor_end := Station_3S2,
    go := Panel.run_mode, t_stall := T#2s, robust := ROBUST);

Station_3Y1 := Arm.valve_to_home;  // Arm_to_Magazine
Station_3Y2 := Arm.valve_to_end;   // Arm_to_Subsequent
Station_H1  := Panel.start_light;
Station_H2  := Panel.reset_light;
Panel_H4    := Panel.error_mode;   // Q2
END_PROGRAM
