# SCADA for Sorting Station: Purpose (Milestone S3.1)

*Half-page writeup.*

The Sorting station's SCADA interface is the **supervisory window onto the final
sort-and-dispatch stage**. It provides **remote Start/Stop/Reset control** and
mirrors the **start / reset / Q1** lights, and its distinctive job is to show
**where every workpiece is going and how full each slide is**.

It shows:

- the **conveyor** running and the **two deflector branches** (home / in-between /
  end);
- the **colour and material** of each workpiece as the recognition sensors read it
  (metal, red, or black), and therefore which slide it is bound for;
- the **number of pieces on each of the three slides**, so the operator can see a
  slide approaching full;
- **animated** workpiece transitions as pieces travel the belt and are deflected.

Its purpose is to let an operator supervise the sort: confirm each piece is routed
correctly, watch the slide fill levels, and catch a full slide or a fault (Q2, e.g.
a held branch) the moment it happens. It is the operator's view of the line's final
distribution logic.
