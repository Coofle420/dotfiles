#!/usr/bin/env bash
# Stop Artix's installer leftover from generating a NEW machine-id on every boot.
# (Cider, Steam and other apps tie logins/updates to the machine-id, so they "forgot" you each boot.)
# Run:  sudo bash ~/rice/fix-machine-id.sh
set -euo pipefail
[ "$EUID" -eq 0 ] || { echo "Run with sudo:  sudo bash $0"; exit 1; }

OFF=/etc/local.d.disabled
mkdir -p "$OFF"

echo "== 1/3 disable the boot scripts (moved, not deleted)"
for f in change-machine-id.start artix-icons.start; do
  if [ -e "/etc/local.d/$f" ]; then mv -v "/etc/local.d/$f" "$OFF/"; else echo "   (already gone: $f)"; fi
done

echo "== 2/3 make the machine-id permanent and consistent"
# Apps (Electron's node-machine-id, dbus) read /var/lib/dbus/machine-id first, so keep THAT value
# as the permanent id: it is the one Cider's current login was most likely built from.
if [ -s /var/lib/dbus/machine-id ] && [ ! -L /var/lib/dbus/machine-id ]; then
  cp -a /etc/machine-id "/etc/machine-id.bak-$(date +%F-%H%M)"
  cat /var/lib/dbus/machine-id > /etc/machine-id
fi
rm -f /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id
chmod 444 /etc/machine-id

echo "== 3/3 verify"
echo "   /etc/machine-id            : $(cut -c1-12 /etc/machine-id)…"
echo "   /var/lib/dbus/machine-id   : $(cut -c1-12 /var/lib/dbus/machine-id)… -> $(readlink /var/lib/dbus/machine-id)"
echo "   remaining boot scripts     : $(ls /etc/local.d/*.start 2>/dev/null | xargs -n1 basename | tr '\n' ' ')"
echo
echo "Done. Reboot twice to confirm: the first line above should be IDENTICAL after each reboot."
echo "Undo: sudo mv $OFF/change-machine-id.start /etc/local.d/"
