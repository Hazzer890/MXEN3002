# SCADA for Testing Station: Purpose (Milestone S2.1)

*Half-page writeup.*

The Testing station's SCADA interface is a **supervisory window onto the inspection
stage**. Like the Distributing HMI it provides **remote Start/Stop/Reset control**
and mirrors the **start / reset / Q1** lights, but its distinctive job is to make
the **inspection result visible**: for each workpiece in process it shows the
**colour** (white or other) and **height** (tall or short) the station has
determined, and the **destination slide** it is being sent to.

It shows:

- the **lift** position (down / in-between / up) and the **ejecting cylinder**
  position (home / in-between / end);
- the **workpiece locations**, including pieces that have come to rest on the
  **bottom slide** and **top slide**;
- the **colour and height** of the piece currently being tested, once the sensors
  have read it;
- **animated** workpiece transitions as pieces are lifted, classified and ejected.

Its purpose is to let an operator watch the quality-gate decision happen and see why
a piece went to the top or bottom slide, and catch a full slide or a fault (Q2)
as it happens. It is the operator's view of the station's inspect-and-sort logic.
