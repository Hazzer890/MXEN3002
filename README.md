# MXEN3002 — Mechatronic Automation Project

Lab deliverables for the Festo MPS line (Distributing, Testing, Sorting)
programmed in Omron Sysmac Studio, simulated in CIROS, with SCADA in Ignition.

Everything is under [`deliverables/`](deliverables/). Start with:

- **[`deliverables/LAB_WALKTHROUGH.md`](deliverables/LAB_WALKTHROUGH.md)** — the
  in-lab guide: per session, what to load, what to demo, and which doc to read for
  each of the 70 marks.
- **[`deliverables/logbook/LOGBOOK.pdf`](deliverables/logbook/LOGBOOK.pdf)** — the
  whole project as one print-ready logbook.
- **[`deliverables/README.md`](deliverables/README.md)** — the full index.

The shared control design is four function blocks (`FB_Panel`, `FB_Actuator_T1`,
`FB_Actuator_T2`, `FB_Actuator_T3`) reused across the three stations, delivered as
type-in-ready Structured Text plus a PLCopen import under
[`deliverables/usb/`](deliverables/usb/).

> The unit's source PDFs (Curtin course material) are kept local and are not part
> of this repository.
