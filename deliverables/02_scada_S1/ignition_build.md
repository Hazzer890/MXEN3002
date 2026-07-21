# Ignition Build Guide — Distributing Station (Milestone S1.2)

Step-by-step to build the SCADA screen in Ignition Designer. Reference: Ignition
User Manual (docs.inductiveautomation.com, v8.0). S1.2 requires: 3 buttons, 3
lights (start / reset / Q1), workpiece + actuator positions for both actuators,
and animation of workpiece transitions.

## 1. Device connection + tag map

Connect Ignition to the PLC (the same Omron controller Sysmac transfers to) via the
**Gateway > OPC UA / Device Connections**. Then create OPC tags that point at the
station variables. Every tag maps to a variable you already entered in the Sysmac
I/O map (`../usb/io_tables/distributing.tsv`), so the names line up.

| Ignition tag | Source (PLC var) | Dir | Purpose |
|---|---|---|---|
| `Dist/Start_PB` | `Panel_S1` | write | Start button |
| `Dist/Stop_PB` | `Panel_S2` | write | Stop button |
| `Dist/Reset_PB` | `Panel_S4` | write | Reset button |
| `Dist/StartLight` | `Station_H1` | read | start light |
| `Dist/ResetLight` | `Station_H2` | read | reset light |
| `Dist/Q1` | `Panel_H3` | read | batch complete |
| `Dist/Q2` | `Panel_H4` | read | error |
| `Dist/Arm_Magazine` | `Station_3S1` | read | arm at magazine (home) |
| `Dist/Arm_Downstream` | `Station_3S2` | read | arm at downstream (end) |
| `Dist/Ej_Retracted` | `Station_1B1` | read | ejector home |
| `Dist/Ej_Extended` | `Station_1B2` | read | ejector end |
| `Dist/Vacuum` | `Station_2B1` | read | workpiece gripped |

**Deriving the "in-between" state** (needed for both actuators, since there is no
in-between sensor): a UDT/expression tag per actuator —

- `Arm_State` = `Magazine` if `Arm_Magazine`, `Downstream` if `Arm_Downstream`,
  else **`In-between`**.
- `Ej_State` = `Home` if `Ej_Retracted`, `End` if `Ej_Extended`, else
  **`In-between`**.

Add these as **Expression tags**:
```
if({[~]Dist/Arm_Magazine}, 0, if({[~]Dist/Arm_Downstream}, 2, 1))
```
(0 = magazine, 1 = in-between, 2 = downstream; same pattern for the ejector).

> If your bench cannot connect Ignition directly to the Omron PLC, build the tags
> as **Memory tags** and drive them from CIROS via the OPC/EasyPort bridge, or
> demo against memory tags you toggle — the screen and bindings are identical.

## 2. Screen layout (Vision window or Perspective view)

Create a window `Distributing`. Drop these components:

**Control panel group (top-left)**
- 3 **Momentary buttons** labelled Start / Stop / Reset. Bind each button's action
  to write TRUE-while-pressed to `Dist/Start_PB` / `Stop_PB` / `Reset_PB`
  (momentary write, so it behaves like a real pushbutton).
- 3 **Multi-state indicators / LEDs**: Start (green), Reset (amber), Q1 (blue).
  Bind each LED's "on" to the matching read tag. Add a red **Q2** lamp too — it
  makes the error state visible even though S1.2 lists only three lights.

**Process view (centre) — the animation**
- Draw the station schematic: a **magazine** (left), the **swivel arm** as a line
  pivoting between magazine and downstream, and the **ejecting cylinder** as a bar
  that extends/retracts, with a **downstream hand-off** point on the right.
- Place a small **workpiece** rectangle that moves along the path.

## 3. Animation bindings

**Swivel arm angle** — bind the arm graphic's `rotation` (Vision) or a CSS
transform (Perspective) to `Arm_State`:
- `0` → point at magazine (e.g. 0°), `2` → point downstream (e.g. 90°), `1` →
  half-way (45°). Use a **map/expression binding**:
  `if({Arm_State}=0, 0, if({Arm_State}=2, 90, 45))`.

**Ejecting cylinder position** — bind the cylinder bar's X position (or width) to
`Ej_State`: home → retracted X, end → extended X, in-between → mid.

**Workpiece position** — bind the workpiece rectangle's X/Y to a small expression
that follows the active actuator: while the ejector extends, move the piece out of
the magazine; while the arm swivels with `Vacuum` true, move it along the arm path
to downstream. A simple approach: drive the workpiece from `Arm_State` and
`Ej_State` with an expression that picks the piece's location from whichever
actuator is currently carrying it.

**Colour feedback** — bind the arm/cylinder fill to turn amber while `In-between`
(moving) and green at a limit; turn everything red when `Dist/Q2` is on.

## 4. Test

1. Put the PLC in RUN with the distributing program (see `../usb/IMPORT_GUIDE.md`).
2. In Designer, enter preview/runtime mode.
3. Press **Start** → Start LED on, arm animates through the 7-step cycle, workpiece
   moves magazine → downstream, repeating 5×; **Q1** lights after the 5th.
4. Press **Stop** mid-cycle → arm freezes on screen; **Start** → resumes.
5. Press **Reset** → actuators animate home, Reset LED on then off (back to Pause).

That satisfies every S1.2 bullet: 3 buttons, 3 lights, both actuators' three
positions, workpiece positions, and animated transitions.
