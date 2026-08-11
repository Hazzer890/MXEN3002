(*  Test_EjectorT2  --  Milestones 1.7 / 1.8: ejection cylinder alone.
    Distributing I/O. Stroke-completing: pause finishes the stroke to a limit.
    FSM: 01_distributing/fsm_T2.md
*)
PROGRAM Test_EjectorT2
VAR Panel : FB_Panel; Ejector : FB_Actuator_T2; ROBUST : BOOL := FALSE; END_VAR

Panel(s1_start := Panel_S1, s2_stop := NOT Panel_S2, (* Stop wired NC *) s4_reset := Panel_S4,
      error_in := ROBUST AND Ejector.error, reset_done := Ejector.at_home);
Ejector(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_1B1, sensor_end := Station_1B2,
    go := Panel.run_mode, t_stall := T#2s, robust := ROBUST);

Station_1Y1 := Ejector.valve_extend;   // Magazine_Eject
Station_H1  := Panel.start_light;
Station_H2  := Panel.reset_light;
Panel_H4    := Panel.error_mode;       // Q2
END_PROGRAM
