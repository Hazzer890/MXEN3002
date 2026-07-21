# Sorting Station: Purpose (Milestone 3.1)

*Half-page writeup. Source: CIROS Mechatronics station help and Festo MPS
documentation. Reword for your logbook.*

The Sorting station is the **third and final station**, the distribution and
dispatch stage of the line. It **sorts finished workpieces onto three slides
according to material and colour**.

A **conveyor belt** (`Station_K1`) carries workpieces past a set of **recognition
sensors** near the start of the belt:

- a **metallic sensor** (`Station_B2`), inductive, true for metal pieces;
- an **optical sensor** (`Station_B3`, "workpiece not black") that separates black
  from the rest.

From these two signals every piece falls into one of three classes:

| Class | Sensors | Slide |
|---|---|---|
| **Metal** | `B2` = 1 | Slide 1 (branch 1) |
| **Red** (non-metal, not black) | `B2` = 0, `B3` = 1 | Slide 2 (branch 2) |
| **Black** | `B3` = 0 | Slide 3 (straight through) |

Two **deflector branches** do the sorting: short pneumatic cylinders
(`Station_1Y1` branch 1, `Station_2Y1` branch 2, each with retracted/extended
sensors) push a piece off the belt into slide 1 or 2. Pieces left undeflected
continue to the end of the belt and drop into slide 3. A **retractable stopper**
(`Station_3Y1`) at the belt entry releases pieces one at a time, and a
**slide-full sensor** (`Station_B4`) stops the station when a slide is full.

The station reuses the shared control-panel and actuator blocks: the two branches
are `FB_Actuator_T2` (the Distributing ejection-cylinder block), and the stopper is
`FB_Actuator_T3`. This reuse is what milestone L.1 credits.

The Sorting station reads each workpiece's material and colour on a conveyor and
deflects it onto one of three slides. It is the final sort-and-dispatch stage of
the line.
