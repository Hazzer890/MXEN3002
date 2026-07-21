# Single-actuator test harnesses (Session 1, and 2.2–2.5)

The deployable programs in `../` are the full-station `Main_*` programs. Milestones
1.4–1.8 and 2.2–2.5 are demonstrated with one block at a time, so these five tiny
programs drive a single FB. Paste one as an ST program (see
`../../IMPORT_GUIDE.md` fallback path), bind the I/O map for that station, and run.

| Harness | Milestones | Station I/O | Flip for robust |
|---|---|---|---|
| `Test_Panel.st` | 1.4 | Distributing | — |
| `Test_Arm.st` | 1.5 / 1.6 | Distributing | `ROBUST := TRUE` for 1.6 |
| `Test_EjectorT2.st` | 1.7 / 1.8 | Distributing | `ROBUST := TRUE` for 1.8 |
| `Test_Lift.st` | 2.2 / 2.3 | Testing | `ROBUST := TRUE` for 2.3 |
| `Test_EjectorT3.st` | 2.4 / 2.5 | Testing | `ROBUST := TRUE` for 2.5 |

Each drives its actuator continuously (`go := Panel.run_mode`) so you can exercise
run / pause / reset / resume and the stall behaviour. They use the same FBs you
deploy later, so nothing here is throwaway logic.
