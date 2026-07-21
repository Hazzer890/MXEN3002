# Ignition Build Guide — Testing Station (Milestone S2.2)

Same Designer workflow as `../02_scada_S1/ignition_build.md` (device connection,
momentary buttons, LED indicators, position/animation bindings). Only the tags and
the two extra requirements — **piece colour/height** and **bottom-slide pieces** —
differ. Build S1 first; this reuses that method.

## Tag map (from `../usb/io_tables/testing.tsv`)

| Ignition tag | PLC var | Dir | Purpose |
|---|---|---|---|
| `Test/Start_PB` / `Stop_PB` / `Reset_PB` | `Panel_S1/S2/S4` | write | buttons |
| `Test/StartLight` / `ResetLight` / `Q1` / `Q2` | `Station_H1/H2/H3/H4` | read | lights |
| `Test/Part_AV` | `Part_AV` | read | workpiece present |
| `Test/NotBlack` | `Station_B2` | read | colour: 1 = white/red-metal, 0 = black |
| `Test/HeightOK` | `Station_B5` | read | height: 1 = tall, 0 = short |
| `Test/Lift_Up` | `Station_1B1` | read | lift at top (end) |
| `Test/Lift_Down` | `Station_1B2` | read | lift at bottom (home) |
| `Test/Ej_Retracted` | `Station_2B1` | read | ejector home |
| `Test/Beam` | `Station_B4` | read | safety beam (1 = clear) |

**Derived (expression) tags:**
- `Lift_State` = `0` down / `2` up / `1` in-between →
  `if({[~]Test/Lift_Down},0,if({[~]Test/Lift_Up},2,1))`
- `Colour` = when `Part_AV`: `Black` if `NOT NotBlack`, else `White` if `NOT
  HeightOK`, else `Red/Metal`. (White = not black + short; red/metal = not black +
  tall.)
- `Height` = `Tall` if `HeightOK` else `Short` (only meaningful once lifted).
- The **top/bottom slide counts** are internal to `Main_Testing`. Expose them by
  adding two INT variables to the program (`top`, `bottom` already exist) and
  mapping them to OPC tags `Test/TopCount`, `Test/BottomCount`; bind on-screen
  numeric labels to them. (If they can't be exposed, count `Ej_Retracted`
  extend→retract cycles per destination in an Ignition expression as a fallback.)

## Screen additions beyond S1

1. **Lift** graphic (vertical bar) — Y position bound to `Lift_State`
   (down/mid/up). **Ejecting cylinder** bar bound to its home/end state.
2. **Colour/height readout** — a text label bound to `Colour` and `Height`; colour
   the label swatch (white / red / silver / black) to match, shown only while
   `Part_AV`.
3. **Two slides** — draw the top and bottom slides; place small workpiece markers
   whose count is bound to `Test/TopCount` / `Test/BottomCount` (e.g. show N blocks
   stacked). Animate a piece sliding down the relevant slide when a count
   increments.
4. **Blower** indicator — a small icon bound to `Station_3Y1` (air cushion) that
   pulses during a top-slide transfer.
5. **Q1** turns on when the bottom slide is full (5); **Q2** red on error.

## Test

Run the Testing program (see `../usb/IMPORT_GUIDE.md`), Start, and feed white /
red-metal / black pieces: watch the lift animate, the colour/height readout update,
pieces land on the correct slide with the counts incrementing, and the blower pulse
for top-slide pieces. Stop mid-lift → freeze; Reset → home. Fill the bottom slide →
Q1; hold the lift or block the beam → Q2.
