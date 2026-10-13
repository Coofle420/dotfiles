#!/usr/bin/env bash
# Install the MilkGrub GRUB theme and boot straight into linux-cachyos.
# Run:  sudo bash ~/rice/install-milkgrub.sh
#
# What it does (all reversible, backups are made first):
#   1. backs up /etc/default/grub and /boot/grub/grub.cfg
#   2. installs the theme (prepared in ~/rice/milkgrub-build) to /boot/grub/themes/MilkGrub
#   3. sets: theme, 2560x1440 -> 1920x1080 -> auto resolution, 2 second countdown
#   4. regenerates grub.cfg, finds the exact menu entry of the linux-cachyos kernel
#      and makes it the default (the stock "linux" kernel stays in the menu as a fallback)
set -euo pipefail

[ "$EUID" -eq 0 ] || { echo "Run with sudo:  sudo bash $0"; exit 1; }

USER_HOME=$(getent passwd "${SUDO_USER:-tree}" | cut -d: -f6)
SRC="$USER_HOME/rice/milkgrub-build"
THEME_DIR=/boot/grub/themes/MilkGrub
STAMP=$(date +%F-%H%M)

[ -f "$SRC/theme.txt" ] && [ -f "$SRC/assets/background.png" ] || { echo "Theme files missing in $SRC"; exit 1; }
command -v grub-mkconfig >/dev/null || { echo "grub-mkconfig not found"; exit 1; }

echo "== 1/4 backups"
cp -a /etc/default/grub "/etc/default/grub.pre-milkgrub-$STAMP"
[ -f /boot/grub/grub.cfg ] && cp -a /boot/grub/grub.cfg "/boot/grub/grub.cfg.pre-milkgrub-$STAMP"
echo "   /etc/default/grub.pre-milkgrub-$STAMP"

echo "== 2/4 install theme -> $THEME_DIR"
rm -rf "$THEME_DIR"
mkdir -p "$THEME_DIR"
cp -r "$SRC"/. "$THEME_DIR"/
chown -R root:root "$THEME_DIR"
chmod -R go-w "$THEME_DIR"

echo "== 3/4 edit /etc/default/grub"
python3 -I - <<'PY'
import re
p = "/etc/default/grub"
lines = open(p).read().splitlines()

def set_kv(key, value):
    global lines
    pat = re.compile(r'^\s*(export\s+)?' + re.escape(key) + r'=')
    out, done = [], False
    for ln in lines:
        if pat.match(ln):
            if not done:
                out.append(f'{key}={value}')
                done = True
            # drop duplicate lines of the same key
        else:
            out.append(ln)
    if not done:
        out.append(f'{key}={value}')
    lines = out

set_kv("GRUB_THEME", '"/boot/grub/themes/MilkGrub/theme.txt"')
set_kv("GRUB_GFXMODE", '"2560x1440x32,1920x1080x32,auto"')
set_kv("GRUB_GFXPAYLOAD_LINUX", '"keep"')
set_kv("GRUB_TERMINAL_OUTPUT", '"gfxterm"')
set_kv("GRUB_TIMEOUT", "2")
set_kv("GRUB_TIMEOUT_STYLE", "menu")
set_kv("GRUB_DEFAULT", '"0"')          # temporary; replaced with the cachyos entry below
open(p, "w").write("\n".join(lines) + "\n")
PY

echo "== 4/4 regenerate grub.cfg and select linux-cachyos"
grub-mkconfig -o /boot/grub/grub.cfg

# ---- locate the linux-cachyos menu entry (embedded parser) ----
DEFAULT_ID=$(python3 -I - /boot/grub/grub.cfg <<'PY'
import re, sys
cfg = open(sys.argv[1]).read()
sub = re.search(r"submenu '[^']*'[^\n]*?\$menuentry_id_option '(gnulinux-advanced-[^']+)'", cfg)
entry = None
for m in re.finditer(r"menuentry '([^']*)'[^\n]*?\$menuentry_id_option '(gnulinux-[^']*advanced-[^']+)'", cfg):
    title, eid = m.group(1), m.group(2)
    low = title.lower()
    if "linux-cachyos" in low and "fallback" not in low and "recovery" not in low:
        entry = eid
        break
if entry:
    print((sub.group(1) + ">" if sub else "") + entry)
PY
)

if [ -n "$DEFAULT_ID" ]; then
    echo "   linux-cachyos entry: $DEFAULT_ID"
    python3 -I - "$DEFAULT_ID" <<'PY'
import re, sys
p = "/etc/default/grub"
s = open(p).read()
s = re.sub(r'(?m)^GRUB_DEFAULT=.*$', 'GRUB_DEFAULT="%s"' % sys.argv[1], s)
open(p, "w").write(s)
PY
    grub-mkconfig -o /boot/grub/grub.cfg
else
    echo "   !! could not find a linux-cachyos entry; leaving the default as the first entry."
    echo "      (the theme is still installed; send me the output of: grep -E \"menuentry|submenu\" /boot/grub/grub.cfg)"
fi

echo
echo "== summary =="
grep -E '^\s*(set theme=|set default=|set timeout=|set gfxmode=)' /boot/grub/grub.cfg | sed 's/^\s*/   /' | head
echo
echo "Done. Reboot to see it. To undo:"
echo "  sudo cp /etc/default/grub.pre-milkgrub-$STAMP /etc/default/grub && sudo grub-mkconfig -o /boot/grub/grub.cfg"
