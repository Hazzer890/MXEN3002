#!/usr/bin/env python3
"""Generate 00_plan/gantt.xlsx -- the P.1 Gantt chart as a real Excel file.

Zero dependencies (stdlib zipfile + XML strings), so it also runs on the lab PC.
An .xlsx is a zip of SpreadsheetML parts; we emit the minimum: content types,
rels, one worksheet, and a styles part with the fills/borders the Gantt needs.

The schedule mirrors gantt.md: pre-lab prep + five weekly sessions (Weeks 2-6),
one row per milestone claim, a colour-coded bar per session across a day grid,
and a marks summary. Dates are indicative -- edit the Week header / bars to your
own lab timetable.
"""
import zipfile, datetime, html

# ---- schedule: (session_key, milestones, week_label, marks, day_start, span) ----
# day_start/span index a compact working-day grid (1 task per day, no calendar
# gaps between weeks -- a sequential staircase, which is honest since the claims
# are done in order).
TASKS = [
    ("prep", "Read docs + IO maps",            "Prep",   0, 1, 1),
    ("prep", "FB design + FSM design",         "Prep",   0, 2, 2),
    ("prep", "ST / PLCopen / docs",            "Prep",   0, 4, 2),
    ("s1", "P.1  Gantt + strategy",            "Week 2", 1, 6, 1),
    ("s1", "1.1  tick-tock sample",            "Week 2", 1, 7, 1),
    ("s1", "1.2 / 1.3  purpose + interface",   "Week 2", 2, 8, 1),
    ("s1", "1.4  panel FSM",                   "Week 2", 2, 9, 1),
    ("s1", "1.5 / 1.6  arm proper + robust",   "Week 2", 4, 10, 1),
    ("s1", "1.7 / 1.8  ejector proper + robust", "Week 2", 4, 11, 1),
    ("s2", "1.9 / 1.10  station proper + robust", "Week 3", 6, 12, 1),
    ("s2", "1.11  revise Gantt",               "Week 3", 1, 13, 1),
    ("s2", "S1.1 / S1.2  SCADA",               "Week 3", 5, 14, 1),
    ("s2", "2.1  purpose",                     "Week 3", 1, 15, 1),
    ("s2", "2.2 / 2.3  lift (reuse T1)",       "Week 3", 2, 16, 1),
    ("s3", "2.4 / 2.5  ejector T3",            "Week 4", 4, 17, 1),
    ("s3", "2.6 / 2.7  station proper + robust", "Week 4", 5, 18, 1),
    ("s3", "2.8  revise Gantt",                "Week 4", 1, 19, 1),
    ("s3", "S2.1 / S2.2  SCADA",               "Week 4", 5, 20, 1),
    ("s4", "3.1 / 3.2  station proper + robust", "Week 5", 3, 21, 1),
    ("s4", "3.3  robust",                      "Week 5", 3, 22, 1),
    ("s4", "3.4  revise Gantt",                "Week 5", 1, 23, 1),
    ("s4", "S3.1 / S3.2  SCADA",               "Week 5", 5, 24, 1),
    ("s4", "L.1  FB reuse demo",               "Week 5", 3, 25, 1),
    ("s5", "L.2  line proper",                 "Week 6", 5, 26, 1),
    ("s5", "L.3  line robust",                 "Week 6", 6, 27, 1),
]
NDAYS = 27
SESSION_COLS = {  # cellXfs style index for each session's bar
    "prep": 5, "s1": 6, "s2": 7, "s3": 8, "s4": 9, "s5": 10,
}
SESSION_NAME = {"prep": "Prep (done)", "s1": "Session 1", "s2": "Session 2",
                "s3": "Session 3", "s4": "Session 4", "s5": "Session 5"}
WEEK_GROUPS = [("Prep", 1, 5), ("Week 2", 6, 11), ("Week 3", 12, 16),
               ("Week 4", 17, 20), ("Week 5", 21, 25), ("Week 6", 26, 27)]


def col_letter(n):           # 1-indexed -> A, B, ... AA
    s = ""
    while n:
        n, r = divmod(n - 1, 26)
        s = chr(65 + r) + s
    return s


def esc(t):
    return html.escape(str(t), quote=True)


# ------------------------------------------------------------------ styles.xml
STYLES = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
<fonts count="5">
  <font><sz val="11"/><name val="Calibri"/></font>
  <font><b/><sz val="11"/><name val="Calibri"/></font>
  <font><b/><sz val="11"/><color rgb="FFFFFFFF"/><name val="Calibri"/></font>
  <font><b/><sz val="14"/><color rgb="FF1F497D"/><name val="Calibri"/></font>
  <font><sz val="8"/><name val="Calibri"/></font>
</fonts>
<fills count="12">
  <fill><patternFill patternType="none"/></fill>
  <fill><patternFill patternType="gray125"/></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FF1F497D"/></patternFill></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FFD9D9D9"/></patternFill></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FF4F81BD"/></patternFill></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FF9BBB59"/></patternFill></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FFF79646"/></patternFill></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FF8064A2"/></patternFill></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FF4BACC6"/></patternFill></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FFC0504B"/></patternFill></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FFF2F2F2"/></patternFill></fill>
  <fill><patternFill patternType="solid"><fgColor rgb="FFE7E6E6"/></patternFill></fill>
</fills>
<borders count="2">
  <border><left/><right/><top/><bottom/><diagonal/></border>
  <border>
    <left style="thin"><color rgb="FFBFBFBF"/></left>
    <right style="thin"><color rgb="FFBFBFBF"/></right>
    <top style="thin"><color rgb="FFBFBFBF"/></top>
    <bottom style="thin"><color rgb="FFBFBFBF"/></bottom>
  </border>
</borders>
<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
<cellXfs count="16">
  <xf fontId="0" fillId="0" borderId="0"/>                                                                
  <xf fontId="2" fillId="2" borderId="1" applyFont="1" applyFill="1" applyBorder="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf>
  <xf fontId="1" fillId="0" borderId="1" applyFont="1" applyBorder="1"><alignment horizontal="left" vertical="center"/></xf>
  <xf fontId="0" fillId="0" borderId="1" applyBorder="1"><alignment horizontal="center" vertical="center"/></xf>
  <xf fontId="0" fillId="10" borderId="1" applyFill="1" applyBorder="1"/>
  <xf fontId="0" fillId="3" borderId="1" applyFill="1" applyBorder="1"/> 
  <xf fontId="0" fillId="4" borderId="1" applyFill="1" applyBorder="1"/> 
  <xf fontId="0" fillId="5" borderId="1" applyFill="1" applyBorder="1"/> 
  <xf fontId="0" fillId="6" borderId="1" applyFill="1" applyBorder="1"/> 
  <xf fontId="0" fillId="7" borderId="1" applyFill="1" applyBorder="1"/> 
  <xf fontId="0" fillId="8" borderId="1" applyFill="1" applyBorder="1"/> 
  <xf fontId="1" fillId="0" borderId="1" applyFont="1" applyBorder="1"><alignment horizontal="center" vertical="center"/></xf>
  <xf fontId="3" fillId="0" borderId="0" applyFont="1"/>                  
  <xf fontId="4" fillId="2" borderId="1" applyFont="1" applyFill="1" applyBorder="1"><alignment horizontal="center" vertical="center"/></xf>
  <xf fontId="1" fillId="11" borderId="1" applyFont="1" applyFill="1" applyBorder="1"><alignment horizontal="left" vertical="center"/></xf>
  <xf fontId="2" fillId="2" borderId="1" applyFont="1" applyFill="1" applyBorder="1"><alignment horizontal="center" vertical="center"/></xf>
</cellXfs>
</styleSheet>'''

CONTENT_TYPES = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
<Default Extension="xml" ContentType="application/xml"/>
<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
<Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
</Types>'''

RELS = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
</Relationships>'''

WORKBOOK = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
 xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
<sheets><sheet name="Gantt" sheetId="1" r:id="rId1"/></sheets>
</workbook>'''

WB_RELS = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>'''


def cell(ref, style, value=None, num=False):
    if value is None or value == "":
        return f'<c r="{ref}" s="{style}"/>'
    if num:
        return f'<c r="{ref}" s="{style}"><v>{value}</v></c>'
    return f'<c r="{ref}" s="{style}" t="inlineStr"><is><t xml:space="preserve">{esc(value)}</t></is></c>'


def build_sheet():
    rows = []
    merges = []
    DAY0 = 5                       # first day column index (E)

    # row 1: title
    rows.append((1, [cell("A1", 12, "MXEN3002 Lab Project — Gantt (P.1)")]))
    merges.append("A1:D1")
    # row 2: note
    rows.append((2, [cell("A2", 0,
        "Five weekly 3h sessions to 70/70. Bars are colour-coded by session; "
        "dates are indicative — set them to your lab timetable.")]))
    merges.append("A2:" + col_letter(DAY0 + NDAYS - 1) + "2")

    # row 3: group (week) header across day columns
    r3 = [cell("A3", 15, "Timeline →")]
    merges.append("A3:D3")
    for name, ds, de in WEEK_GROUPS:
        c0, c1 = DAY0 + ds - 1, DAY0 + de - 1
        r3.append(cell(col_letter(c0) + "3", 15, name))
        if c1 > c0:
            merges.append(f"{col_letter(c0)}3:{col_letter(c1)}3")
    rows.append((3, r3))

    # row 4: column header
    r4 = [cell("A4", 1, "Session"), cell("B4", 1, "Milestone(s)"),
          cell("C4", 1, "Week"), cell("D4", 1, "Marks")]
    for d in range(1, NDAYS + 1):
        r4.append(cell(col_letter(DAY0 + d - 1) + "4", 13, f"D{d}"))
    rows.append((4, r4))

    # task rows
    R = 5
    for sess, name, week, marks, start, span in TASKS:
        cells = [cell(f"A{R}", 2, SESSION_NAME[sess]),
                 cell(f"B{R}", 2, name),
                 cell(f"C{R}", 3, week),
                 cell(f"D{R}", 11, marks, num=True)]
        bar = SESSION_COLS[sess]
        for d in range(1, NDAYS + 1):
            col = col_letter(DAY0 + d - 1)
            if start <= d <= start + span - 1:
                cells.append(cell(f"{col}{R}", bar))
            else:
                cells.append(cell(f"{col}{R}", 3))
        rows.append((R, cells))
        R += 1

    # spacer + summary block
    R += 1
    rows.append((R, [cell(f"A{R}", 14, "Mark-claim summary")]))
    merges.append(f"A{R}:D{R}")
    R += 1
    rows.append((R, [cell(f"A{R}", 1, "Session"), cell(f"B{R}", 1, "Claim"),
                     cell(f"C{R}", 1, ""), cell(f"D{R}", 1, "Marks")]))
    summary = [
        ("Session 1", "P.1, 1.1–1.8", 14),
        ("Session 2", "1.9, 1.10, 1.11, S1.1, S1.2, 2.1, 2.2, 2.3", 15),
        ("Session 3", "2.4–2.8, S2.1, S2.2", 15),
        ("Session 4", "3.1–3.4, S3.1, S3.2, L.1", 15),
        ("Session 5", "L.2, L.3", 11),
        ("TOTAL", "", 70),
    ]
    for sname, claim, m in summary:
        R += 1
        st = 14 if sname == "TOTAL" else 2
        rows.append((R, [cell(f"A{R}", st, sname), cell(f"B{R}", st, claim),
                         cell(f"C{R}", st, ""),
                         cell(f"D{R}", 11, m, num=True)]))
        if claim:
            merges.append(f"B{R}:C{R}")

    # assemble rows XML
    body = []
    for rn, cells in rows:
        body.append(f'<row r="{rn}">' + "".join(cells) + "</row>")

    # column widths
    cols = ('<cols>'
            '<col min="1" max="1" width="12" customWidth="1"/>'
            '<col min="2" max="2" width="34" customWidth="1"/>'
            '<col min="3" max="3" width="8" customWidth="1"/>'
            '<col min="4" max="4" width="7" customWidth="1"/>'
            f'<col min="5" max="{DAY0 + NDAYS - 1}" width="3.3" customWidth="1"/>'
            '</cols>')
    merge_xml = ('<mergeCells count="%d">' % len(merges)
                 + "".join(f'<mergeCell ref="{m}"/>' for m in merges)
                 + "</mergeCells>")
    dim = f"A1:{col_letter(DAY0 + NDAYS - 1)}{R}"
    return f'''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
<dimension ref="{dim}"/>
<sheetViews><sheetView workbookViewId="0"><pane xSplit="4" ySplit="4" topLeftCell="E5" activePane="bottomRight" state="frozen"/></sheetView></sheetViews>
<sheetFormatPr defaultRowHeight="15"/>
{cols}
<sheetData>
{''.join(body)}
</sheetData>
{merge_xml}
<pageMargins left="0.3" right="0.3" top="0.5" bottom="0.5" header="0.3" footer="0.3"/>
<pageSetup orientation="landscape" fitToWidth="1" fitToHeight="0" paperSize="9"/>
</worksheet>'''


def main(path):
    sheet = build_sheet()
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("[Content_Types].xml", CONTENT_TYPES)
        z.writestr("_rels/.rels", RELS)
        z.writestr("xl/workbook.xml", WORKBOOK)
        z.writestr("xl/_rels/workbook.xml.rels", WB_RELS)
        z.writestr("xl/styles.xml", STYLES)
        z.writestr("xl/worksheets/sheet1.xml", sheet)
    print("wrote", path)


if __name__ == "__main__":
    import os
    main(os.path.join(os.path.dirname(os.path.abspath(__file__)), "gantt.xlsx"))
