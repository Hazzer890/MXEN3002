# SCADA for Distributing Station: Purpose (Milestone S1.1)

*Half-page writeup describing the SCADA interface's purpose.*

The SCADA interface (built in **Ignition**) is a **supervisory window onto the
Distributing station**: it lets an operator **observe and control the station from
a screen** instead of the physical panel, and shows the live state of the process
as it runs.

It serves three purposes:

1. **Remote control.** On-screen **Start, Stop and Reset** buttons drive the same
   `FB_Panel` state machine as the physical buttons, so the station can be operated
   from the HMI.

2. **Status indication.** The **start light, reset light and Q1** lamps mirror the
   panel lights, so the operator can read the station's mode (Run / Pause / Reset /
   batch-complete) at a glance, the same one-light-at-a-time interlock as the real
   panel.

3. **Process visualisation.** The screen shows **where the workpiece and the two
   actuators are** (the swivel arm in-magazine / in-between / in-downstream, and
   the ejecting cylinder home / in-between / end), with **animation** so the
   operator watches workpieces move through the station in real time and can spot a
   jam or a mis-feed as it happens.

In short, the SCADA layer turns the PLC's internal signals into a live operator
picture and a remote control point: the human-machine interface for the station.
