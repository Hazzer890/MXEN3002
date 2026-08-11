(*  Test_Panel  --  Milestone 1.4: control panel only, no actuators.
    Distributing I/O. reset_done := FALSE so RESET exits only on Stop, which is
    exactly what the 1.4 invalid-transition steps test. FSM: 01_distributing/fsm_panel.md
*)
PROGRAM Test_Panel
VAR Panel : FB_Panel; END_VAR

Panel(s1_start := Panel_S1, s2_stop := NOT Panel_S2, (* Stop wired NC *) s4_reset := Panel_S4,
      error_in := FALSE, reset_done := FALSE);

Station_H1 := Panel.start_light;   // start light
Station_H2 := Panel.reset_light;   // reset light
Panel_H3   := FALSE;               // Q1
Panel_H4   := Panel.error_mode;    // Q2
END_PROGRAM
