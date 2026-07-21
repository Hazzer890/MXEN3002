# Ignition Build Guide — Sorting Station (Milestone S3.2)

Same Designer workflow as `../02_scada_S1/ignition_build.md`. Station-specific tags
and two extra requirements — **colour/material readout** and **per-slide piece
counts** — below.

## Tag map (from `../usb/io_tables/sorting.tsv`)

| Ignition tag | PLC var | Dir | Purpose |
|---|---|---|---|
| `Sort/Start_PB` / `Stop_PB` / `Reset_PB` | `Panel_S1/S2/S4` | write | buttons |
| `Sort/StartLight` / `ResetLight` / `Q1` / `Q2` | `Station_H1/H2/H3/H4` | read | lights |
| `Sort/Part_AV` | `Part_AV` | read | workpiece present |
| `Sort/Metal` | `Station_B2` | read | metallic |
| `Sort/NotBlack` | `Station_B3` | read | not black |
| `Sort/SlideFull` | `Station_B4` | read | a slide is full |
| `Sort/B1_Ret` / `B1_Ext` | `Station_1B1` / `1B2` | read | branch 1 home/end |
| `Sort/B2_Ret` / `B2_Ext` | `Station_2B1` / `2B2` | read | branch 2 home/end |
| `Sort/Conveyor` | `Station_K1` | read | belt running |

**Derived (expression) tags:**
- `Material` = when `Part_AV`: `Metal` if `Metal`, `Red` if `NotBlack AND NOT
  Metal`, else `Black`. (Same classification as `Main_Sorting`.)
- `B1_State` / `B2_State` = home / in-between / end →
  `if({[~]Sort/B1_Ret},0,if({[~]Sort/B1_Ext},2,1))`.
- **Slide counts** — the three counters `s1c/s2c/s3c` live in `Main_Sorting`.
  Expose them as OPC tags `Sort/Slide1`, `Sort/Slide2`, `Sort/Slide3` and bind
  numeric labels. (Fallback: count branch extend cycles / end-of-belt arrivals in
  Ignition expressions.)

## Screen additions beyond S1

1. **Conveyor** — an arrow/belt graphic whose motion (or a "running" tint) binds to
   `Sort/Conveyor`.
2. **Two branches** — deflector bars whose extend animates on `B1_State` /
   `B2_State`.
3. **Colour/material readout** — a label bound to `Material`, swatch coloured
   silver / red / black, shown while `Part_AV`.
4. **Three slides with counters** — draw slides 1 (metal), 2 (red), 3 (black); show
   a numeric count and a stack of N piece-markers bound to `Sort/Slide1..3`.
   Animate a piece sliding down when a count increments.
5. **Q1** on when any slide is full (and the station goes to error — `Q2` also on
   per test 3.1.2); **Q2** red on error.

## Test

Run the Sorting program (see `../usb/IMPORT_GUIDE.md`), Start, and feed metal / red
/ black pieces: the material readout updates, the correct branch animates, and the
matching slide count increments. Stop with a piece on the belt → conveyor stops;
Start → resumes and sorts correctly. Fill a slide → Q1 + Q2 (error); hold a branch
→ Q2.
