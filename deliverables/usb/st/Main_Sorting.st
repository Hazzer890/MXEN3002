(*
  Main_Sorting  --  Station 3 top-level program (milestone 3.1 / 3.2).

  Blocks (5): FB_Panel, FB_Actuator_T2 (branch 1), FB_Actuator_T2 (branch 2),
  FB_Actuator_T3 (stopper, single-acting timed release), and THIS Main. Main owns
  the conveyor (Station_K1), the sort decision, the three slide counters, the
  slide-full interlock and Q1/Q2.

  Classification:
    metal := Station_B2                 -> branch 1 (slide 1)
    red   := Station_B3 AND NOT Station_B2 (not black, not metal) -> branch 2 (slide 2)
    black := NOT Station_B3             -> straight through (slide 3)
  Any slide full (Station_B4 or a counter at cap) -> Q1 ON and station -> ERROR
  (test 3.1.2). Set ROBUST := FALSE for 3.1, TRUE for 3.2.
*)
PROGRAM Main_Sorting
VAR
    Panel   : FB_Panel;
    Branch1 : FB_Actuator_T2;
    Branch2 : FB_Actuator_T2;
    Stopper : FB_Actuator_T3;      // timed release, no limit switch
    pos     : INT := 0;            // conveyor position of the current piece 0..3
    dest    : INT := 0;            // 0 branch1  1 branch2  2 straight
    have    : BOOL;                // a piece is being routed
    s1c, s2c, s3c : INT := 0;      // slide counts (cap 5)
    conveyor, go_b1, go_b2, go_stop : BOOL;
    metal, red, black, slide_full : BOOL;
    fault, reset_done : BOOL;
    ROBUST : BOOL := TRUE;
    CAP    : INT  := 5;
END_VAR

reset_done := Branch1.at_home AND Branch2.at_home;
Panel(s1_start := Panel_S1, s2_stop := Panel_S2, s4_reset := Panel_S4,
      error_in := fault, reset_done := reset_done);

IF Panel.reset_mode OR Panel.error_mode THEN
    have := FALSE; pos := 0;
END_IF;

slide_full := Station_B4 OR (s1c >= CAP) OR (s2c >= CAP) OR (s3c >= CAP);

conveyor := FALSE; go_b1 := FALSE; go_b2 := FALSE; go_stop := FALSE;
IF Panel.run_mode AND NOT slide_full THEN
    IF NOT have THEN
        IF Part_AV THEN                        // classify newly released piece
            metal := Station_B2;
            black := NOT Station_B3;
            red   := Station_B3 AND NOT Station_B2;
            IF metal THEN dest := 0;
            ELSIF red THEN dest := 1;
            ELSE dest := 2; END_IF;
            have := TRUE; pos := 0;
            go_stop := TRUE;                   // pulse stopper to admit the piece
        END_IF;
    ELSE
        CASE dest OF
        0:  (* branch 1 *)
            IF pos < 1 THEN conveyor := TRUE; pos := pos + 1;
            ELSE
                go_b1 := TRUE;
                IF Branch1.at_end THEN s1c := s1c + 1; have := FALSE; END_IF;
            END_IF;
        1:  (* branch 2 *)
            IF pos < 2 THEN conveyor := TRUE; pos := pos + 1;
            ELSE
                go_b2 := TRUE;
                IF Branch2.at_end THEN s2c := s2c + 1; have := FALSE; END_IF;
            END_IF;
        2:  (* straight through to end slide *)
            IF pos < 3 THEN conveyor := TRUE; pos := pos + 1;
            ELSE s3c := s3c + 1; have := FALSE; END_IF;
        END_CASE;
    END_IF;
END_IF;

Branch1(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_1B1, sensor_end := Station_1B2, go := go_b1,
    t_stall := T#2s, robust := ROBUST);

Branch2(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_2B1, sensor_end := Station_2B2, go := go_b2,
    t_stall := T#2s, robust := ROBUST);

Stopper(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := TRUE, go := go_stop,
    t_stroke := T#1s, t_stall := T#2s, robust := ROBUST);

// Robust faults (3.2): a branch stalled/held, or any slide full. Piece-removed
// (a piece taken off the conveyor before a slide) is inferred as: routing a
// piece but Part_AV lost mid-line -- VERIFY sensor behaviour on the bench.
fault := (ROBUST AND (Branch1.error OR Branch2.error))
    OR (Panel.run_mode AND slide_full)
    OR (ROBUST AND Panel.run_mode AND have AND pos >= 1 AND NOT Part_AV);

// ---- physical outputs ----
Station_K1  := conveyor AND NOT Panel.error_mode;   // Conveyor Motor ON
Station_1Y1 := Branch1.valve_extend;                // Branch 1 extend
Station_2Y1 := Branch2.valve_extend;                // Branch 2 extend
Station_3Y1 := Stopper.valve_extend;                // Stopper retract (release)
Station_H1  := Panel.start_light;
Station_H2  := Panel.reset_light;
Station_H3  := slide_full;                          // Q1
Station_H4  := Panel.error_mode;                    // Q2
IP_N_FO     := Panel.run_mode;                      // station occupied

END_PROGRAM
