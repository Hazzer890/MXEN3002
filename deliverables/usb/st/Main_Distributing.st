(*
  Main_Distributing  --  Station 1 top-level program (milestone 1.9 / 1.10).

  Blocks (milestone 1.9 asks for 4): FB_Panel, FB_Actuator_T1 (arm),
  FB_Actuator_T2 (ejector), and THIS Main. Main owns everything the FBs must
  not: the vacuum (Station_2Y1) and ejector-pulse (Station_2Y2) valves, the
  unused sensors (Station_B4 magazine-empty, IP_FI), the Q1/Q2 lights, the
  7-step cycle sequencer, and the 5-piece batch counter.

  Set ROBUST := FALSE to demo 1.9 (proper), TRUE to demo 1.10 (robust).
  The 7-step cycle mirrors milestone 1.9's numbered list exactly.
*)
PROGRAM Main_Distributing
VAR
    Panel   : FB_Panel;
    Arm     : FB_Actuator_T1;     // swivel arm  (home = magazine)
    Ejector : FB_Actuator_T2;     // magazine ejection cylinder
    si         : INT := 0;        // sequence step 0..6
    cycles     : INT := 0;        // workpieces completed this batch
    grip, drop : INT := 0;        // dwell counters for vacuum grip / drop
    go_arm, go_ej : BOOL;
    vacuum, eject_pulse : BOOL;
    fault, reset_done   : BOOL;
    ROBUST : BOOL := TRUE;        // 1.10 = TRUE, 1.9 = FALSE
    MAG    : INT  := 5;           // magazine capacity / batch size
END_VAR

reset_done := Arm.at_home AND Ejector.at_home;
Panel(s1_start := Panel_S1, s2_stop := Panel_S2, s4_reset := Panel_S4,
      error_in := fault, reset_done := reset_done);

IF Panel.reset_mode OR Panel.error_mode THEN
    si := 0; grip := 0; drop := 0; vacuum := FALSE; eject_pulse := FALSE;
    IF Panel.reset_mode THEN cycles := 0; END_IF;
END_IF;

go_arm := FALSE; go_ej := FALSE; eject_pulse := FALSE;
IF Panel.run_mode AND cycles < MAG THEN
    CASE si OF
    0:  go_arm := TRUE;  IF Arm.at_end  THEN si := 1; END_IF;   (* 1 arm downstream *)
    1:  go_ej  := TRUE;  IF Ejector.at_end  THEN si := 2; END_IF; (* 2 ejector push  *)
    2:  go_arm := TRUE;  IF Arm.at_home THEN si := 3; END_IF;   (* 3 arm upstream  *)
    3:  vacuum := TRUE;  grip := grip + 1;                       (* 4 vacuum grips  *)
        IF grip >= 1 THEN grip := 0; si := 4; END_IF;
    4:  go_ej := FALSE;  IF Ejector.at_home THEN si := 5; END_IF; (* 5 ejector retract *)
    5:  go_arm := TRUE;  IF Arm.at_end  THEN si := 6; END_IF;   (* 6 arm to end    *)
    6:  eject_pulse := TRUE; vacuum := FALSE; drop := drop + 1;  (* 7 drop + vac off *)
        IF drop >= 1 THEN drop := 0; cycles := cycles + 1; si := 0; END_IF;
    END_CASE;
END_IF;

Arm(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_3S1, sensor_end := Station_3S2, go := go_arm,
    t_stall := T#2s, robust := ROBUST);

Ejector(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_1B1, sensor_end := Station_1B2, go := go_ej,
    t_stall := T#2s, robust := ROBUST);

// Robust faults (1.10): stalled actuator, piece pulled off the vacuum
// (vacuum commanded but Station_2B1 gripped-sensor lost), or arm reaching the
// magazine with it empty (Station_B4).
fault := ROBUST AND ( Arm.error OR Ejector.error
    OR (Panel.run_mode AND vacuum AND NOT Station_2B1)
    OR (Panel.run_mode AND Arm.at_home AND Station_B4 AND si <> 0) );

// ---- physical outputs ----
Station_3Y2 := Arm.valve_to_end;       // Arm_to_Subsequent (downstream)
Station_3Y1 := Arm.valve_to_home;      // Arm_to_Magazine
Station_1Y1 := Ejector.valve_extend;   // Magazine_Eject
Station_2Y1 := vacuum      AND NOT Panel.error_mode;   // Vacuum_On
Station_2Y2 := eject_pulse AND NOT Panel.error_mode;   // Ejector_Pulse_On
Station_H1  := Panel.start_light;      // start light
Station_H2  := Panel.reset_light;      // reset light
Panel_H3    := (cycles >= MAG);        // Q1  batch of 5 complete
Panel_H4    := Panel.error_mode;       // Q2  error
// IP_FI (succeeding-station-free) is jumpered TRUE stand-alone; for the
// integrated line (L.2) gate step 6 delivery on IP_FI.

END_PROGRAM
