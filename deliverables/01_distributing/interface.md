# Distributing Station: Operator Interface (Milestone 1.3)

*Half-page writeup: what each of the 3 buttons does and what each of the 4 lights
means. This is the human interface to the `FB_Panel` state machine (see
`fsm_panel.md`).*

The station is operated from a panel with **three buttons** and **four lights**.
The buttons request state changes; the lights report the current state. The panel
enforces one simple rule: **only one operational light (Start or Reset) is ever
on**, so the operator can always read the mode at a glance.

## The three buttons

| Button | Address | What it does |
|---|---|---|
| **Start** | `Panel_S1` | From **Pause**, starts the station (→ Run). Ignored in Reset and Error (an invalid request causes no change). |
| **Stop**  | `Panel_S2` | From **Run**, stops the station back to **Pause**. Also exits **Reset** back to Pause. It is the "return to a safe idle" button. |
| **Reset** | `Panel_S4` | From **Pause**, puts the station into **Reset**, driving all actuators to their home positions. From **Error**, it is the first step of the error-recovery sequence (clears the fault, then homes). |

The station **can only be started or reset from the Pause state**. This safety
interlock sits behind every test protocol.

## The four lights

| Light | Address | Meaning |
|---|---|---|
| **Start light** | `Station_H1` | ON = station is in **Run**. OFF = Pause. |
| **Reset light** | `Station_H2` | ON = station is in **Reset** (homing). |
| **Q1** | `Panel_H3` | Process/status light. On this station: **the batch of workpieces is complete** (magazine emptied / 5 delivered). |
| **Q2** | `Panel_H4` | **Error** light. ON = the station is in the error state; all valves are off. Cleared only by the reset sequence (Reset then Start). |

## How they work together

- **Power-on →** everything off, station in **Pause**.
- **Start** → Start light on (Run). **Stop** → Start light off (Pause).
- **Reset** (from Pause) → Reset light on; **Stop** or homing-complete → back to
  Pause, Reset light off.
- A fault (a held actuator, a lost workpiece) → **Q2 on**, valves off; recover
  with **Reset** then **Start**.

The Start and Reset lights are never on together; the interlock in `FB_Panel`
guarantees it.
