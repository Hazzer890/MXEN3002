# Testing Station — I/O Table (Sysmac Part 7)

Input word 0, output word 1. Pasteable: `../usb/io_tables/testing.tsv`.

## Inputs (word 0)

| Name | Addr | Function | Used by |
|---|---|---|---|
| `Part_AV` | 0.00 | Workpiece available | Main |
| `Station_B2` | 0.01 | Workpiece **not** black | Main (`black := NOT B2`) |
| `Station_B4` | 0.02 | Safety through-beam (TRUE = clear) | Main (interlock) |
| `Station_B5` | 0.03 | Workpiece height correct (tall) | Main (`tall`) |
| `Station_1B1` | 0.04 | Lifting cylinder **up** | FB_Actuator_T1 `sensor_end` |
| `Station_1B2` | 0.05 | Lifting cylinder **down** | FB_Actuator_T1 `sensor_home` |
| `Station_2B1` | 0.06 | Ejecting cylinder retracted | FB_Actuator_T3 `sensor_home` |
| `IP_FI` | 0.07 | Succeeding station free | Main (integrated line) |
| `Panel_S1` | 0.08 | Start | FB_Panel |
| `Panel_S2` | 0.09 | Stop | FB_Panel |
| `Panel_S4` | 0.11 | Reset | FB_Panel |

## Outputs (word 1)

| Name | Addr | Function | Driven by |
|---|---|---|---|
| `Station_1Y1` | 1.00 | Lift down | FB_Actuator_T1 `valve_to_home` |
| `Station_1Y2` | 1.01 | Lift up | FB_Actuator_T1 `valve_to_end` |
| `Station_2Y1` | 1.02 | Advance ejecting cylinder | FB_Actuator_T3 `valve_extend` |
| `Station_3Y1` | 1.03 | Air cushion (blower) | Main (~1 s to top slide) |
| `IP_N_FO` | 1.07 | Station occupied | Main (integrated line) |
| `Station_H1` | 1.08 | Start light | FB_Panel |
| `Station_H2` | 1.09 | Reset light | FB_Panel |
| `Station_H3` | 1.10 | Q1 (bottom slide full) | Main |
| `Station_H4` | 1.11 | Q2 (error) | Main = FB_Panel `error_mode` |

## Actuator wiring summary

- **Lift → FB_Actuator_T1** (reused from Station 1). home = **down** (`1B2`/`1Y1`),
  end = **up** (`1B1`/`1Y2`). This is the L.1 reuse of `FB_Actuator_T1` on the
  Distributing **and** Testing stations.
- **Ejecting cylinder → FB_Actuator_T3** (single sensor: only retracted `2B1`).
  Extended end is inferred by the stroke timer. Single solenoid `2Y1`.
- **Blower `Station_3Y1`, height `Station_B5`, colour `Station_B2`, safety beam
  `Station_B4`** are Main-owned (the "unused sensors/valves in a block" the
  milestone asks for).

> Home/end convention: for the lift, "home" is the **down** rest position and
> "end" is **up** — so `sensor_home := Station_1B2` (down) and `sensor_end :=
> Station_1B1` (up) at the call site.
