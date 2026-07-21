# USB deployment guide — MXEN3002 Festo stations

Everything here was designed against the station finite-state diagrams and test
protocols. It cannot be
compiled without Sysmac Studio, so two deployment paths ship together:

1. **Primary — PLCopen XML** (`plcopen/*.xml`): one self-contained file per
   station, imported directly. Fastest.
2. **Fallback — plain ST + TSV** (`st/*.st`, `io_tables/*.tsv`): paste by hand.
   Guaranteed to work on any Sysmac version. Worst case is a few minutes of
   pasting, not retyping.

Do the version check first, then follow path 1. If the import misbehaves, drop to
path 2 — the code is identical.

---

## 0. Version check (30 seconds)

`Help > About Sysmac Studio`. If the version is **≥ v1.30**, PLCopen import is
available. If lower, skip to *Fallback* below.

## 1. Primary path — import the PLCopen XML

Per station (start with `distributing.xml`):

1. `File > Import…`  → select `plcopen/<station>.xml`.
2. When prompted for the target, import into the current project's
   **Programming > POUs**. You should see four POUs appear:
   - `FB_Panel`, plus the two actuator FBs for that station, and the station
     `Main_*` program.
3. Open **Configurations and Setup > I/O Map**. Confirm the global variable names
   (`Panel_S1`, `Station_3S2`, …) resolve. If any program symbol shows unresolved
   (red), it just needs binding in the I/O map — do step 2 of the fallback.
4. Register the `Main_*` program in the task if it is not already: **Task Settings
   > PrimaryTask > Program Assignment > add `Main_<station>`.**
5. Go to **2. Bind the I/O map** below (always required — the XML addresses are a
   convenience, the I/O map is authoritative).

> One project per station is cleanest (three suitcases, three PLCs). If you keep
> all three in one project, import each XML into its own POU folder and assign the
> matching `Main_*` to the task before transferring to that station's PLC.

## 2. Bind the I/O map (required, both paths)

The physical mapping lives in the Sysmac I/O map, not the code.

1. **Offline** (Ctrl+Shift+W).
2. Double-click **I/O Map** under Configurations and Setup.
3. Scroll to **CJ1W-ID211 (DC Input Unit)** — the input channels.
   For each row in `io_tables/<station>.tsv` with a `0.xx` address, type the
   **Name** into the Variable column of the matching `Ch1_In00…` entry
   (address `0.01` → `Ch1_In01`, etc. — the input word is word 0).
4. Scroll to **CJ1W-OC211 (Relay Output Unit)** — the output channels.
   For each row with a `1.xx` address, type the Name into the matching
   `Ch1_Out00…` (output word is word 1).
5. Variable names must match the code exactly and contain **no spaces**.

The TSV columns are `Name  Address  Type  Comment` — paste the Name against the
address shown. Comments are for your logbook; they need not be entered.

## 3. Transfer and run

1. Go **Online** (Ctrl+W) — Communication Setup must already be configured for
   this suitcase's PLC IP (`134.7.44.xxx`, label by the Ethernet port). If not:
   `Controller > Communications Setup > Ethernet connection via a hub >` enter IP
   `> Ethernet Communications Test >` expect "Test OK".
2. **Transfer to Controller** (Ctrl+T) → Execute → Yes/OK to all prompts.
3. **Controller > Mode > RUN**.
4. Launch CIROS on the right-hand bench PC (the left has no EasyPort) and run the
   station model, or operate the real station.

## 4. Tuning (do this at the bench)

The stall/stroke timers are **FB inputs**, not constants, because real cylinders
differ from the model:

- `t_stall` (all robust FBs): raise if a healthy stroke ever trips a false Q2;
  lower if a genuine hold takes too long to be caught. Start at `T#2s`.
- `t_stroke` (T3 only — testing ejector, sorting stopper): set just longer than
  the real extend travel time, since that end has no limit switch.
- `Main_*` has a `ROBUST` boolean: `FALSE` demos the "proper" milestone, `TRUE`
  the "robust" one. Flip it and re-transfer between the two claims.

**Verify the beam polarity on the Testing station:** `Main_Testing` treats
`beam_blocked := NOT Station_B4` (through-beam TRUE = clear). If the interlock
behaves inverted on the bench, flip that one line.

---

## Fallback path — paste ST by hand

If PLCopen import is unavailable or misbehaves:

1. For each POU in `st/` (create FBs first, then the `Main_*` program):
   - Right-click **Programming > POUs > Function Blocks > Add > Function Block**
     (or **Programs > Add > ST Program** for the `Main_*`). Name it exactly as the
     file (e.g. `FB_Panel`).
   - Set the language to **Structured Text**.
   - Open the file in `st/`, copy the `VAR…END_VAR` declarations into the
     variable table, and the code body into the ST editor. (Sysmac separates the
     declaration table from the body; the `.st` file has both in order.)
2. Bind the I/O map (section 2 above).
3. Assign `Main_<station>` to the PrimaryTask.
4. Transfer and run (section 3).

Files per station:

| Station | FBs to add | Program | I/O table |
|---|---|---|---|
| Distributing | FB_Panel, FB_Actuator_T1, FB_Actuator_T2 | Main_Distributing | distributing.tsv |
| Testing | FB_Panel, FB_Actuator_T1, FB_Actuator_T3 | Main_Testing | testing.tsv |
| Sorting | FB_Panel, FB_Actuator_T2, FB_Actuator_T3 | Main_Sorting | sorting.tsv |

`FB_Panel` is byte-for-byte the same file on all three stations — that shared
reuse is exactly what milestone L.1 credits.
