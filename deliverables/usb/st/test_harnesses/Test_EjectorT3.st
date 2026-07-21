(*  Test_EjectorT3  --  Milestones 2.4 / 2.5: testing ejecting cylinder alone.
    Testing I/O. Single retract sensor (2B1); extended end is the stroke timer.
    Stall is caught on the retract leg. FSM: 03_testing/fsm_T3.md
*)
PROGRAM Test_EjectorT3
VAR Panel : FB_Panel; Ejector : FB_Actuator_T3; ROBUST : BOOL := FALSE; END_VAR

Panel(s1_start := Panel_S1, s2_stop := Panel_S2, s4_reset := Panel_S4,
      error_in := ROBUST AND Ejector.error, reset_done := Ejector.at_home);
Ejector(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_2B1, go := Panel.run_mode,
    t_stroke := T#700ms, t_stall := T#2s, robust := ROBUST);

Station_2Y1 := Ejector.valve_extend;   // Advance Ejecting Cylinder
Station_H1  := Panel.start_light;
Station_H2  := Panel.reset_light;
Station_H4  := Panel.error_mode;       // Q2
END_PROGRAM
