#!/usr/bin/env python3
"""Build LOGBOOK.html (self-contained, print-ready) from logbook.src.html.

- Renders every <pre class="mermaid" data-title="...">SRC</pre> block to an inline
  SVG via mermaid-cli (mmdc), so the output needs no JS and prints anywhere.
- HTML-escapes every <pre class="code">SRC</pre> block (so the source can hold raw
  ST with < > & characters).
- Optionally prints to LOGBOOK.pdf with headless Chromium.

Deps: mermaid-cli (uses `mmdc` on PATH, else `npx @mermaid-js/mermaid-cli`) and
Chromium (reused via PUPPETEER_EXECUTABLE_PATH). Both were present at build time.
Run:  python3 build_logbook.py
"""
import re, os, subprocess, tempfile, shutil, html, sys

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "logbook.src.html")
OUT = os.path.join(HERE, "LOGBOOK.html")
PDF = os.path.join(HERE, "LOGBOOK.pdf")

CHROMIUM = shutil.which("chromium") or shutil.which("chromium-browser") \
    or shutil.which("google-chrome")
MMDC = shutil.which("mmdc")


def mmdc_cmd(inp, outp, cfg):
    if MMDC:
        base = [MMDC]
    else:
        base = ["npx", "-y", "@mermaid-js/mermaid-cli@11"]
    return base + ["-i", inp, "-o", outp, "-b", "transparent", "-c", cfg,
                   "-p", os.path.join(HERE, ".puppeteer.json")]


MMDC_CFG = '{"theme":"neutral","themeVariables":{"fontSize":"15px"},' \
           '"flowchart":{"htmlLabels":true,"curve":"basis"}}'
PUP_CFG = '{"args":["--no-sandbox"]}'


def render_mermaid(html_text):
    env = dict(os.environ)
    if CHROMIUM:
        env["PUPPETEER_EXECUTABLE_PATH"] = CHROMIUM
    cfg = os.path.join(HERE, ".mmdc.json")
    open(cfg, "w").write(MMDC_CFG)
    open(os.path.join(HERE, ".puppeteer.json"), "w").write(PUP_CFG)

    blocks = list(re.finditer(
        r'<pre class="mermaid"(?:\s+data-title="([^"]*)")?\s*>(.*?)</pre>',
        html_text, re.S))
    print(f"rendering {len(blocks)} diagrams...")
    out = []
    last = 0
    for i, m in enumerate(blocks):
        out.append(html_text[last:m.start()])
        title = m.group(1) or ""
        src = m.group(2).strip()
        with tempfile.TemporaryDirectory() as td:
            mmd = os.path.join(td, "d.mmd")
            svg = os.path.join(td, "d.svg")
            open(mmd, "w").write(src)
            r = subprocess.run(mmdc_cmd(mmd, svg, cfg), env=env,
                               capture_output=True, text=True, cwd=HERE)
            if r.returncode != 0 or not os.path.exists(svg):
                print(f"  diagram {i} FAILED:\n{r.stderr[-800:]}")
                sys.exit(1)
            svg_text = open(svg).read()
            svg_text = re.sub(r'<\?xml[^>]*\?>', '', svg_text).strip()
        cap = f'<figcaption>{html.escape(title)}</figcaption>' if title else ''
        out.append(f'<figure class="diagram">{svg_text}{cap}</figure>')
        last = m.end()
        print(f"  [{i+1}/{len(blocks)}] {title}")
    out.append(html_text[last:])
    return "".join(out)


def escape_code(html_text):
    def repl(m):
        return f'<pre class="code">{html.escape(m.group(1))}</pre>'
    return re.sub(r'<pre class="code">(.*?)</pre>', repl, html_text, flags=re.S)


def main():
    text = open(SRC).read()
    text = render_mermaid(text)     # mermaid first (SVG contains < >)
    text = escape_code(text)        # then escape only code blocks
    open(OUT, "w").write(text)
    print("wrote", OUT)
    if CHROMIUM:
        cmd = [CHROMIUM, "--headless=new", "--no-sandbox", "--disable-gpu",
               "--no-pdf-header-footer",
               "--virtual-time-budget=15000",
               f"--print-to-pdf={PDF}", "file://" + OUT]
        r = subprocess.run(cmd, capture_output=True, text=True)
        if os.path.exists(PDF):
            print("wrote", PDF)
        else:
            # older chromium: --headless without =new
            cmd[1] = "--headless"
            subprocess.run(cmd, capture_output=True, text=True)
            print("wrote", PDF if os.path.exists(PDF) else "(PDF failed; HTML ok)")
    # tidy temp configs
    for f in (".mmdc.json", ".puppeteer.json"):
        p = os.path.join(HERE, f)
        if os.path.exists(p):
            os.remove(p)


if __name__ == "__main__":
    main()
