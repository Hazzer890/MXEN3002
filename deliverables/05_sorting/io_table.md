# Sorting Station — I/O Table (Sysmac Part 7)

Input word 0, output word 1. Pasteable: `../usb/io_tables/sorting.tsv`.

## Inputs (word 0)

| Name | Addr | Function | Used by |
|---|---|---|---|
| `Part_AV` | 0.00 | Workpiece available | Main |
| `Station_B2` | 0.01 | Metallic workpiece | Main (metal) |
| `Station_B3` | 0.02 | Workpiece **not** black | Main (black := NOT B3) |
| `Station_B4` | 0.03 | Slide full | Main (Q1 + error) |
| `Station_1B1` | 0.04 | Branch 1 retracted | FB_Actuator_T2 (b1) `sensor_home` |
| `Station_1B2` | 0.05 | Branch 1 extended | FB_Actuator_T2 (b1) `sensor_end` |
| `Station_2B1` | 0.06 | Branch 2 retracted | FB_Actuator_T2 (b2) `sensor_home` |
| `Station_2B2` | 0.07 | Branch 2 extended | FB_Actuator_T2 (b2) `sensor_end` |
| `Panel_S1` | 0.08 | Start | FB_Panel |
| `Panel_S2` | 0.09 | Stop | FB_Panel |
| `Panel_S4` | 0.11 | Reset | FB_Panel |

## Outputs (word 1)

| Name | Addr | Function | Driven by |
|---|---|---|---|
| `Station_K1` | 1.00 | Conveyor motor on | Main |
| `Station_1Y1` | 1.01 | Branch 1 extend | FB_Actuator_T2 (b1) `valve_extend` |
| `Station_2Y1` | 1.02 | Branch 2 extend | FB_Actuator_T2 (b2) `valve_extend` |
| `Station_3Y1` | 1.03 | Stopper retract (release) | FB_Actuator_T3 (stopper) `valve_extend` |
| `IP_N_FO` | 1.07 | Station occupied | Main |
| `Station_H1` | 1.08 | Start light | FB_Panel |
| `Station_H2` | 1.09 | Reset light | FB_Panel |
| `Station_H3` | 1.10 | Q1 (slide full) | Main |
| `Station_H4` | 1.11 | Q2 (error) | Main = FB_Panel `error_mode` |

## Actuator wiring summary

- **Branch 1 → FB_Actuator_T2 (b1):** home `1B1`, end `1B2`, valve `1Y1`.
- **Branch 2 → FB_Actuator_T2 (b2):** home `2B1`, end `2B2`, valve `2Y1`.
  Both are the **same block reused** from the Distributing ejector (L.1).
- **Stopper → FB_Actuator_T3:** no limit switch (`sensor_home := TRUE`, timed
  release), valve `3Y1`. This is the L.1 reuse of `FB_Actuator_T3` on the Testing
  **and** Sorting stations.
- **`Station_K1` (conveyor), `Station_B2/B3/B4` (recognition + slide-full)** are
  Main-owned — the "unused sensors/valves in a block" that 3.2 requires.
