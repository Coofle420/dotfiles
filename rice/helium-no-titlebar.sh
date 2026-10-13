#!/usr/bin/env bash
# Close Helium first, then run this. Removes Helium's title bar / window buttons.
set -euo pipefail
if pgrep -f 'opt/helium-browser-bin/chrome' >/dev/null; then
  echo "Helium is still running — close it completely first (Menu > Exit), then re-run."; exit 1
fi
P="$HOME/.config/net.imput.helium/Default/Preferences"
cp "$P" "$P.bak-titlebar"
python3 -I - "$P" <<'PY'
import json,sys
p=sys.argv[1]; d=json.load(open(p))
d.setdefault("browser",{})["custom_chrome_frame"]=False
json.dump(d,open(p,"w"),separators=(",",":"))
print("title bar disabled")
PY
