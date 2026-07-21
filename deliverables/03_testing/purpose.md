# Testing Station: Purpose (Milestone 2.1)

*Half-page writeup. Source: CIROS Mechatronics station help and Festo MPS
documentation. Reword for your logbook.*

The Testing station is the **second station**, the quality gate of the line. It
**inspects each workpiece and sorts it by material/colour and height**, passing
acceptable pieces on and rejecting the rest.

A workpiece arrives from the Distributing station and is checked in place by
**recognition sensors**:

- an **optical/colour sensor** (`Station_B2`, "workpiece not black") that
  separates black pieces from the rest;
- the material/colour combined with a **height check** that splits the remaining
  pieces into white (short) and red/metal (tall).

Sorting is then done by two actuators:

1. **The lifting cylinder.** A double-acting **lift** (`Station_1Y1` down /
   `Station_1Y2` up, sensed by `Station_1B1` up and `Station_1B2` down) raises the
   workpiece to a **height sensor** (`Station_B5`). Whether the sensor is made at
   the raised position tells the station if the piece is tall (red/metal) or short
   (white).

2. **The ejecting cylinder and air-slide.** An **ejecting cylinder**
   (`Station_2Y1`) pushes the workpiece onto one of two slides. An **air cushion /
   blower** (`Station_3Y1`) switches on for about a second to help the piece glide
   down the **upper slide**; other pieces go to the **lower slide**.

A **safety through-beam** (`Station_B4`) guards the moving lift. A broken beam
holds the lift; a prolonged obstruction raises an error. The station reuses the
**same control-panel and actuator function blocks** as the Distributing station:
the lift is `FB_Actuator_T1`, the swivel-arm block from Station 1.

The Testing station lifts each workpiece to a height sensor, classifies it by
colour and height, and ejects it to the correct slide. It is the
inspection-and-sort stage of the line.
