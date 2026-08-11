(*
  Main_Testing  --  Station 2 top-level program (milestone 2.6 / 2.7).

  Blocks (4): FB_Panel, FB_Actuator_T1 (lift, REUSED from Station 1),
  FB_Actuator_T3 (ejector, single retract sensor), and THIS Main. Main owns the
  colour/height sort logic, the blower (Station_3Y1), the top/bottom slide
  counters, the safety-beam interlock, and Q1/Q2.

  Piece classification from sensors:
    black   := NOT Station_B2         (B2 = "workpiece not black")
    tall    := Station_B5             (height correct = tall = red/metal)
    white   = not black AND not tall   -> bottom slide
    red/metal = not black AND tall     -> top slide (blower 1 s), or bottom slide if top full
    black                              -> bottom slide, no lift; top slide (lifted) if bottom full

  Beam polarity: Station_B4 is a through-beam (TRUE = clear). beam_blocked below
  is NOT Station_B4 -- VERIFY this polarity on the real bench and flip if needed.
  Set ROBUST := FALSE for 2.6, TRUE for 2.7.
*)
PROGRAM Main_Testing
VAR
    Panel   : FB_Panel;
    Lift    : FB_Actuator_T1;      // home = down, end = up
    Ejector : FB_Actuator_T3;      // single retract sensor
    ps      : INT := 0;            // 0 IDLE 1 LIFTING 2 HEIGHT 3 EJECT_TOP
                                   // 4 EJECT_BOTTOM 5 LOWER
    dest_bottom : BOOL;            // current piece routes to bottom after lower
    bottom, top : INT := 0;        // slide counts (cap 5)
    t_beam  : TON;                 // real-time beam-block dwell before fault
    t_settle : TON;                // let the piece settle at top before sampling B5
    go_lift, go_ej, blower : BOOL;
    black, tall, beam_blocked : BOOL;
    fault, reset_done, beam_fault, proc_fault : BOOL;
    ROBUST : BOOL := FALSE;        // 2.7 = TRUE, 2.6 = FALSE (prove the plain cycle first)
    CAP    : INT  := 5;
END_VAR

reset_done := Lift.at_home AND Ejector.at_home;
Panel(s1_start := Panel_S1, s2_stop := NOT Panel_S2,  // panel Stop is wired NC
      s4_reset := Panel_S4,
      error_in := fault, reset_done := reset_done);

IF Panel.reset_mode OR Panel.error_mode THEN
    ps := 0; proc_fault := FALSE; dest_bottom := FALSE;
END_IF;
IF Panel.reset_mode THEN
    bottom := 0; top := 0;   // operator empties the slides before pressing Reset
END_IF;

beam_blocked := NOT Station_B4;
t_beam(IN := beam_blocked AND (ps = 1 OR ps = 5), PT := T#3s);  // bench-tune
beam_fault := ROBUST AND t_beam.Q;
t_settle(IN := (ps = 2), PT := T#500ms);  // bench-tune

go_lift := FALSE; go_ej := FALSE; blower := FALSE;
IF Panel.run_mode THEN
    CASE ps OF
    0:  (* IDLE: latch class of the presented workpiece *)
        IF Part_AV THEN
            black := NOT Station_B2;
            IF black AND bottom < CAP THEN ps := 4;  // straight to bottom, no lift
            ELSE ps := 1; END_IF;               // lift (black too, if bottom full)
        END_IF;
    1:  (* LIFTING to the height sensor *)
        IF Lift.at_end THEN ps := 2;
        ELSIF NOT beam_blocked THEN go_lift := TRUE; END_IF;
    2:  (* HEIGHT decision, after settle delay *)
        IF t_settle.Q THEN
            tall := Station_B5;
            IF (tall OR black) AND top < CAP THEN
                ps := 3;                        // red/metal, or black diverted -> top slide
            ELSIF ROBUST AND bottom >= CAP THEN
                proc_fault := TRUE;             // bottom full: stop, error (Q2)
            ELSE
                dest_bottom := TRUE; ps := 5;   // white, or tall diverted (top full)
            END_IF;
        END_IF;
    3:  (* EJECT to TOP slide, blower on *)
        go_ej := TRUE; blower := TRUE;
        IF Ejector.at_end THEN top := top + 1; dest_bottom := FALSE; ps := 5; END_IF;
    4:  (* EJECT to BOTTOM slide *)
        go_ej := TRUE;
        IF Ejector.at_end THEN bottom := bottom + 1; ps := 0; END_IF;
    5:  (* LOWER lift home, then dispatch *)
        IF Lift.at_home THEN
            IF dest_bottom THEN ps := 4; ELSE ps := 0; END_IF;
        ELSE go_lift := TRUE; END_IF;
    END_CASE;
END_IF;

Lift(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_1B2, sensor_end := Station_1B1, go := go_lift,
    t_stall := T#2s, robust := ROBUST);

Ejector(run_mode := Panel.run_mode, pause_mode := Panel.pause_mode,
    reset_mode := Panel.reset_mode, error_mode := Panel.error_mode,
    sensor_home := Station_2B1, go := go_ej,
    t_stroke := T#1s, t_stall := T#2s, robust := ROBUST);

fault := ROBUST AND (Lift.error OR Ejector.error OR beam_fault OR proc_fault);

// ---- physical outputs ----
Station_1Y1 := Lift.valve_to_home;     // Lift Down
Station_1Y2 := Lift.valve_to_end;      // Lift Up
Station_2Y1 := Ejector.valve_extend;   // Advance Ejecting Cylinder
Station_3Y1 := blower AND NOT Panel.error_mode;  // Air Cushion (blower, ~1 s)
Station_H1  := Panel.start_light;
Station_H2  := Panel.reset_light;
Station_H3  := (bottom >= CAP);        // Q1  bottom slide full
Station_H4  := Panel.error_mode;       // Q2
IP_N_FO     := Panel.run_mode;         // station occupied (integrated line)

END_PROGRAM
