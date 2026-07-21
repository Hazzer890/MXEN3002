#!/usr/bin/env python3
"""Generate one IEC 61131-10 (PLCopen TC6) XML per station from the .st POUs
and the .tsv I/O tables. Sysmac Studio >= v1.30 imports these via File > Import.

Deliberately mechanical: parses each POU's VAR sections + ST body and wraps them
in the PLCopen schema, so the XML never drifts from the verified .st source.
The station I/O (from io_tables/*.tsv) is emitted as global variables so the
program's symbols resolve; the authoritative hardware binding is still the I/O
map paste (see IMPORT_GUIDE.md).

Run:  python3 gen_plcopen.py      (writes plcopen/*.xml)
"""
import re, os, glob, datetime, html

HERE = os.path.dirname(os.path.abspath(__file__))
ST = os.path.join(HERE, "st")
IOT = os.path.join(HERE, "io_tables")
OUT = os.path.join(HERE, "plcopen")

# station -> (POU files in order, io tsv). Shared FBs are repeated per station
# so each XML is self-contained and imports independently.
STATIONS = {
    "distributing": (["FB_Panel", "FB_Actuator_T1", "FB_Actuator_T2",
                      "Main_Distributing"], "distributing.tsv"),
    "testing":      (["FB_Panel", "FB_Actuator_T1", "FB_Actuator_T3",
                      "Main_Testing"], "testing.tsv"),
    "sorting":      (["FB_Panel", "FB_Actuator_T2", "FB_Actuator_T3",
                      "Main_Sorting"], "sorting.tsv"),
}

ELEM_TYPES = {"BOOL", "INT", "DINT", "REAL", "TIME", "WORD", "BYTE", "LREAL", "UINT"}


def strip_comments(s):
    s = re.sub(r"\(\*.*?\*\)", "", s, flags=re.S)
    s = re.sub(r"//.*", "", s)
    return s


def parse_pou(name):
    raw = open(os.path.join(ST, name + ".st")).read()
    src = strip_comments(raw)
    pou_type = "program" if re.search(r"\bPROGRAM\b", src) else "functionBlock"

    sections = {"inputVars": [], "outputVars": [], "localVars": []}
    smap = {"VAR_INPUT": "inputVars", "VAR_OUTPUT": "outputVars",
            "VAR": "localVars"}
    for kw, key in smap.items():
        for m in re.finditer(kw + r"\b(.*?)END_VAR", src, flags=re.S):
            if kw == "VAR" and m.group(0).startswith(("VAR_INPUT", "VAR_OUTPUT")):
                continue
            for line in m.group(1).split(";"):
                line = line.strip()
                if not line or ":" not in line:
                    continue
                vname, rest = line.split(":", 1)
                vname = vname.strip()
                if not re.match(r"^[A-Za-z_]\w*$", vname):
                    continue
                init = None
                if ":=" in rest:
                    rest, init = rest.split(":=", 1)
                    init = init.strip()
                vtype = rest.strip()
                sections[key].append((vname, vtype, init))

    # body = everything after the last END_VAR up to END_FUNCTION_BLOCK/PROGRAM
    body = raw
    idx = body.rfind("END_VAR")
    body = body[idx + len("END_VAR"):]
    body = re.sub(r"END_(FUNCTION_BLOCK|PROGRAM)\s*$", "", body.strip())
    return pou_type, sections, body.strip()


def type_xml(vtype):
    t = vtype.strip().upper()
    if t in ELEM_TYPES:
        return f"<{t}/>"
    return f'<derived name="{html.escape(vtype.strip())}"/>'


def init_xml(init):
    if init is None:
        return ""
    v = init.strip()
    return (f"<initialValue><simpleValue value=\"{html.escape(v)}\"/>"
            f"</initialValue>")


def vars_xml(varlist, indent):
    out = []
    for vname, vtype, init in varlist:
        out.append(
            f'{indent}<variable name="{vname}">'
            f'<type>{type_xml(vtype)}</type>{init_xml(init)}</variable>')
    return "\n".join(out)


def pou_xml(name):
    ptype, sec, body = parse_pou(name)
    iface = []
    if sec["inputVars"]:
        iface.append("        <inputVars>\n" +
                     vars_xml(sec["inputVars"], "          ") +
                     "\n        </inputVars>")
    if sec["outputVars"]:
        iface.append("        <outputVars>\n" +
                     vars_xml(sec["outputVars"], "          ") +
                     "\n        </outputVars>")
    if sec["localVars"]:
        iface.append("        <localVars>\n" +
                     vars_xml(sec["localVars"], "          ") +
                     "\n        </localVars>")
    body_esc = html.escape(body)
    return f'''    <pou name="{name}" pouType="{ptype}">
      <interface>
{chr(10).join(iface)}
      </interface>
      <body>
        <ST><xhtml xmlns="http://www.w3.org/1999/xhtml">{body_esc}</xhtml></ST>
      </body>
    </pou>'''


def read_globals(tsv):
    rows = []
    for line in open(os.path.join(IOT, tsv)).read().splitlines()[1:]:
        parts = line.split("\t")
        if len(parts) >= 3:
            rows.append((parts[0], parts[1], parts[2], parts[3] if len(parts) > 3 else ""))
    return rows


def addr_xml(address):
    # Omron w.b -> %IX / %QX. word 0 = inputs, word 1 = outputs (per guide).
    word = address.split(".")[0]
    kind = "%IX" if word == "0" else "%QX"
    return kind + address


def globals_xml(rows):
    out = []
    for name, address, vtype, comment in rows:
        out.append(
            f'          <variable name="{name}" address="{addr_xml(address)}">'
            f'<type>{type_xml(vtype)}</type>'
            f'<documentation><xhtml xmlns="http://www.w3.org/1999/xhtml">'
            f'{html.escape(comment)}</xhtml></documentation></variable>')
    return "\n".join(out)


def build(station, pous, tsv):
    now = datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    pous_xml = "\n".join(pou_xml(p) for p in pous)
    gx = globals_xml(read_globals(tsv))
    prog = pous[-1]
    return f'''<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://www.plcopen.org/xml/tc6_0201"
         xmlns:xhtml="http://www.w3.org/1999/xhtml"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <fileHeader companyName="MXEN3002" productName="Festo Station Control"
              productVersion="1.0" creationDateTime="{now}"/>
  <contentHeader name="MXEN3002 {station}">
    <coordinateInfo>
      <fbd><scaling x="1" y="1"/></fbd>
      <ld><scaling x="1" y="1"/></ld>
      <sfc><scaling x="1" y="1"/></sfc>
    </coordinateInfo>
  </contentHeader>
  <types>
    <dataTypes/>
    <pous>
{pous_xml}
    </pous>
  </types>
  <instances>
    <configurations>
      <configuration name="Config0">
        <resource name="Resource0">
          <globalVars>
{gx}
          </globalVars>
          <task name="PrimaryTask" priority="0" interval="T#10ms">
            <pouInstance name="{prog}_inst" typeName="{prog}"/>
          </task>
        </resource>
      </configuration>
    </configurations>
  </instances>
</project>
'''


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for station, (pous, tsv) in STATIONS.items():
        xml = build(station, pous, tsv)
        path = os.path.join(OUT, f"{station}.xml")
        open(path, "w").write(xml)
        print(f"wrote {path} ({len(xml)} bytes)")
