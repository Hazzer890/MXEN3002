(*
  Main_Distributing  --  Station 1 top-level program (milestone 1.9 / 1.10).

  Blocks (milestone 1.9 asks for 4): FB_Panel, FB_Actuator_T1 (arm),
  FB_Actuator_T2 (ejector), and THIS Main. Main owns everything the FBs must
  not: the vacuum (Station_2Y1) and ejector-pulse (Station_2Y2) valves, the
  magazine-empty sensor (Station_B4), IP_FI, the Q1/Q2 lights, and the 7-step
  cycle sequencer. The cycle runs continuously until the magazine runs dry.

  Set ROBUST := FALSE to demo 1.9 (proper), TRUE to demo 1.10 (robust).
  The 7-step cycle mirrors milestone 1.9's numbered list exactly.
*)
PROGRAM Main_Distributing
VAR
    Panel   : FB_Panel;
    Arm     : FB_Actuator_T1;     // swivel arm  (home = magazine)
    Ejector : FB_Actuator_T2;     // magazine ejection cylinder
    si         : INT := 0;        // sequence step 0..6
    t_grip, t_drop : TON;         // real-time dwells: vacuum build-up / release pulse
    go_arm, go_ej : BOOL;
    vacuum, eject_pulse : BOOL;
    fault, reset_done   : BOOL;
    mag_empty  : BOOL;            // magazine out of stock
    ROBUST : BOOL := FALSE;       // 1.10 = TRUE, 1.9 = FALSE (prove the plain cycle first)
END_VAR

reset_done := Arm.at_home AND Ejector.at_home;
Panel(s1_start := Panel_S1, s2_stop := NOT Panel_S2,  // panel Stop is wired NC
      s4_reset := Panel_S4,
      error_in := fault, reset_done := reset_done);

IF Panel.reset_mode OR Panel.error_mode THEN
    si := 0; vacuum := FALSE; eject_pulse := FALSE;
END_IF;

go_arm := FALSE; go_ej := FALSE; eject_pulse := FALSE;
t_grip(IN := (si = 3), PT := T#0.5s);   // vacuum build time before arm departs (bench-tune)
t_drop(IN := (si = 6), PT := T#0.5s);   // release pulse length (bench-tune)
// Station_B4 clears as soon as the LAST piece is staged, while that piece still
// has to be transferred -- so it only means "empty" at the top of a cycle (si=0,
// before the ejector pushes). Latch it there; it self-clears when refilled.
mag_empty := Station_B4 AND (mag_empty OR (Panel.run_mode AND si = 0));

IF Panel.run_mode AND NOT mag_empty THEN
    CASE si OF
    0:  IF Arm.at_end  THEN si := 1; ELSE go_arm := TRUE; END_IF;  (* 1 arm downstream *)
    1:  go_ej := TRUE;  IF Ejector.at_end THEN si := 2; END_IF;    (* 2 ejector push  *)
    2:  IF Arm.at_home THEN si := 3; ELSE go_arm := TRUE; END_IF;  (* 3 arm upstream  *)
    3:  vacuum := TRUE; IF t_grip.Q THEN si := 4; END_IF;          (* 4 vacuum grips  *)
    4:  IF Ejector.at_home THEN si := 5; END_IF;                   (* 5 ejector retract *)
    5:  IF Arm.at_end  THEN si := 6; ELSE go_arm := TRUE; END_IF;  (* 6 arm to end    *)
    6:  eject_pulse := TRUE; vacuum := FALSE;                      (* 7 drop + vac off *)
        IF t_drop.Q THEN si := 0; END_IF;
    END_CASE;
ELSIF Panel.run_mode AND NOT Arm.at_home THEN
    go_arm := TRUE;                    // magazine empty: stow at home
END_IF;

Arm(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_3S1, sensor_end := Station_3S2, go := go_arm,
    t_stall := T#2s, robust := ROBUST);

Ejector(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_1B1, sensor_end := Station_1B2, go := go_ej,
    t_stall := T#2s, robust := ROBUST);

// Robust faults (1.10): stalled actuator, or piece pulled off the vacuum after
// the grip dwell (si >= 4 -- checking during the dwell itself would trip before
// the vacuum has built). An empty magazine is NOT a fault: the mag_empty latch
// above ends the batch cleanly and stows the arm.
fault := ROBUST AND ( Arm.error OR Ejector.error
    OR (Panel.run_mode AND vacuum AND si >= 4 AND NOT Station_2B1) );

// ---- physical outputs ----
Station_3Y2 := Arm.valve_to_end;       // Arm_to_Subsequent (downstream)
Station_3Y1 := Arm.valve_to_home;      // Arm_to_Magazine
Station_1Y1 := Ejector.valve_extend;   // Magazine_Eject
Station_2Y1 := vacuum      AND NOT Panel.error_mode;   // Vacuum_On
Station_2Y2 := eject_pulse AND NOT Panel.error_mode;   // Ejector_Pulse_On
Station_H1  := Panel.start_light;      // start light
Station_H2  := Panel.reset_light;      // reset light
Panel_H3    := mag_empty;              // Q1  magazine empty
Panel_H4    := Panel.error_mode;       // Q2  error
// IP_FI (succeeding-station-free) is jumpered TRUE stand-alone; for the
// integrated line (L.2) gate step 6 delivery on IP_FI.

END_PROGRAM
