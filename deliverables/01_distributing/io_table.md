# Distributing Station — I/O Table (Sysmac Part 7)

Addresses from the Sysmac Studio Quick-Start Guide, Part 7. Input word is **0**,
output word is **1** (Sysmac maps `0.xx → Ch1_In xx`, `1.xx → Ch1_Out xx`).
The pasteable version is `../usb/io_tables/distributing.tsv`.

## Inputs (word 0)

| Name | Addr | Function | Used by |
|---|---|---|---|
| `Station_1B2` | 0.01 | Ejection cylinder **extended** | FB_Actuator_T2 `sensor_end` |
| `Station_1B1` | 0.02 | Ejection cylinder **retracted** | FB_Actuator_T2 `sensor_home` |
| `Station_2B1` | 0.03 | Workpiece gripped (vacuum present) | Main (grip check) |
| `Station_3S1` | 0.04 | Arm at **magazine** (home) | FB_Actuator_T1 `sensor_home` |
| `Station_3S2` | 0.05 | Arm at **downstream** (end) | FB_Actuator_T1 `sensor_end` |
| `Station_B4`  | 0.06 | Magazine empty | Main (unused/robust) |
| `IP_FI`       | 0.07 | Succeeding station free | Main (integrated line) |
| `Panel_S1`    | 0.08 | Start button | FB_Panel |
| `Panel_S2`    | 0.09 | Stop button | FB_Panel |
| `Panel_S4`    | 0.11 | Reset button | FB_Panel |

## Outputs (word 1)

| Name | Addr | Function | Driven by |
|---|---|---|---|
| `Station_1Y1` | 1.00 | Magazine eject (ejection cylinder) | FB_Actuator_T2 `valve_extend` |
| `Station_2Y1` | 1.01 | Vacuum on | **Main** (not in any FB — see 1.9) |
| `Station_2Y2` | 1.02 | Ejector pulse (blow-off) | **Main** (not in any FB — see 1.9) |
| `Station_3Y1` | 1.03 | Arm to magazine | FB_Actuator_T1 `valve_to_home` |
| `Station_3Y2` | 1.04 | Arm to subsequent (downstream) | FB_Actuator_T1 `valve_to_end` |
| `Station_H1`  | 1.08 | Start light | FB_Panel `start_light` |
| `Station_H2`  | 1.09 | Reset light | FB_Panel `reset_light` |
| `Panel_H3`    | 1.10 | Q1 (batch complete) | Main |
| `Panel_H4`    | 1.11 | Q2 (error) | Main = FB_Panel `error_mode` |

## Actuator wiring summary

- **Swivel arm → FB_Actuator_T1** (holdable double-solenoid). home = magazine
  (`3S1`/`3Y1`), end = downstream (`3S2`/`3Y2`).
- **Ejection cylinder → FB_Actuator_T2** (stroke-completing, both sensors).
  home = retracted (`1B1`), end = extended (`1B2`), single solenoid `1Y1`.
- **`Station_2Y1` (vacuum) and `Station_2Y2` (ejector pulse) are owned by Main**,
  never by an actuator FB — milestone 1.9 requires this explicitly.
