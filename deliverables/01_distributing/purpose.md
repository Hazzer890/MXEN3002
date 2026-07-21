# Distributing Station: Purpose (Milestone 1.2)

*Half-page writeup. Source: CIROS Mechatronics station help and Festo MPS
documentation. Reword in your own voice for the logbook.*

The Distributing station is the **first station** in the production line. It
**separates single workpieces from a stack and feeds them, one at a time, to the
next (Testing) station**. The station turns a magazine of stacked blanks into an
ordered, single-file stream.

It does this with two actuators working together:

1. **The ejecting cylinder.** Workpieces sit stacked in a gravity **stack
   magazine**. A double-acting pneumatic **ejecting cylinder** pushes the lowest
   workpiece out of the bottom of the magazine into the pick-up position. A
   through-beam / retro sensor (`Station_B4`) reports when the magazine is empty
   so the station knows to stop.

2. **The swivel arm with vacuum gripper.** A **swivel drive** carries a suction
   cup between two end positions: the **magazine (pick-up)** position and the
   **downstream (hand-over)** position. At pick-up, a **vacuum** (`Station_2Y1`)
   grips the workpiece; the arm swivels across; at hand-over an **ejector pulse**
   (`Station_2Y2`) blows the workpiece off the cup to release it onto the next
   station. Limit switches (`Station_3S1`, `Station_3S2`) confirm each end
   position, and a vacuum sensor (`Station_2B1`) confirms the workpiece is held.

An operator drives the station from a **control panel** (Start / Stop / Reset
buttons and Start / Reset / Q1 / Q2 lights). The station coordinates hand-over
with the next station through the `IP_FI` ("succeeding station free") signal, so
it delivers a workpiece only when the Testing station is ready to receive one.

The Distributing station singulates stacked blanks and swivels each one, under
vacuum, from the magazine to the next station. It is the entry point of the
automated line.
