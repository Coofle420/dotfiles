#!/usr/bin/env bash
# Make SDDM use the qylock theme (R1999_1) and set the monitors to 2560x1440@200Hz + 1920x1080@144Hz
# on every boot and every logout.
# Run:  sudo bash ~/rice/sddm-fix.sh
set -euo pipefail
[ "$EUID" -eq 0 ] || { echo "Run with sudo:  sudo bash $0"; exit 1; }

USER_HOME=$(getent passwd "${SUDO_USER:-tree}" | cut -d: -f6)
NEW_XSETUP="$USER_HOME/rice/Xsetup.new"
XSETUP=/usr/share/sddm/scripts/Xsetup
CONF=/etc/sddm.conf
THEME=R1999_1
STAMP=$(date +%F-%H%M)

[ -f "$NEW_XSETUP" ] || { echo "Missing $NEW_XSETUP"; exit 1; }
[ -d "/usr/share/sddm/themes/$THEME" ] || { echo "Theme $THEME is not installed in /usr/share/sddm/themes"; exit 1; }

echo "== backups"
cp -a "$CONF"   "$CONF.bak-qylock-$STAMP"
cp -a "$XSETUP" "$XSETUP.bak-$STAMP"
echo "   $CONF.bak-qylock-$STAMP"
echo "   $XSETUP.bak-$STAMP"

echo "== theme: Current=$THEME (this file overrides /etc/sddm.conf.d/*)"
if grep -q '^\[Theme\]' "$CONF"; then
  sed -i '/^\[Theme\]/,/^\[/{s/^Current=.*/Current='"$THEME"'/}' "$CONF"
else
  printf '\n[Theme]\nCurrent=%s\n' "$THEME" >> "$CONF"
fi

echo "== resolution script -> $XSETUP"
install -m 0755 -o root -g root "$NEW_XSETUP" "$XSETUP"

echo
echo "== result"
grep -A2 '^\[Theme\]' "$CONF" | sed 's/^/   /'
echo "   Xsetup installed ($(wc -l < "$XSETUP") lines)"
echo
echo "Done. Takes effect at the next login screen (log out or reboot)."
echo "Undo:  sudo cp $CONF.bak-qylock-$STAMP $CONF && sudo cp $XSETUP.bak-$STAMP $XSETUP"
