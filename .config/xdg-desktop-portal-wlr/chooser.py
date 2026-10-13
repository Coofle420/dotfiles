#!/usr/bin/python3 -I
"""xdg-desktop-portal-wlr chooser (chooser_type=simple).
Lists monitors and windows in Noctalia's dmenu, prints "Monitor: <name>" or "Window: <id>"."""
import json, subprocess, sys

def mmsg(what):
    try:
        return json.loads(subprocess.run(["mmsg", "get", what], capture_output=True, text=True, timeout=5).stdout)
    except Exception:
        return {}

entries = []  # (label, xdpw_output)
for m in mmsg("all-monitors").get("monitors", []):
    entries.append((f"Screen  ·  {m['name']}  ·  {m['width']}x{m['height']}", f"Monitor: {m['name']}"))

APPNAMES = {"org.kde.dolphin": "Dolphin", "discord": "Discord", "kitty": "Kitty", "helium": "Helium", "steam": "Steam"}
seen = {}
for c in mmsg("all-clients").get("clients", []):
    tid = c.get("foreign_toplevel_id")
    if not tid:
        continue
    app = APPNAMES.get(c.get("appid", ""), (c.get("appid") or "Window").split(".")[-1].title())
    title = (c.get("title") or "").strip()
    title = title if len(title) <= 55 else title[:54] + "…"
    label = f"Window  ·  {app}  ·  {title}" if title else f"Window  ·  {app}"
    n = seen.get(label, 0); seen[label] = n + 1
    if n: label += f"  ({n + 1})"
    entries.append((label, f"Window: {tid}"))

if len(sys.argv) > 1 and sys.argv[1] == "--dry":
    for l, o in entries: print(f"{l}   ->   {o}")
    sys.exit(0)

if not entries:
    sys.exit(1)
res = subprocess.run(["noctalia", "dmenu", "-p", "Share which screen or window?"],
                     input="\n".join(l for l, _ in entries) + "\n", capture_output=True, text=True)
choice = res.stdout.strip()
for l, o in entries:
    if l == choice:
        print(o); break
