#!/bin/sh
# Runs once from Mango (exec-once): give D-Bus-activated services (portals) the Wayland session env,
# then restart the portal daemons that dinit started at boot with an empty environment.
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus}"
dbus-update-activation-environment WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XCURSOR_THEME XCURSOR_SIZE
sleep 1
# (pkill -x can't match names >15 chars, so match the full command line)
pkill -f '^/usr/lib/xdg-desktop-portal' 2>/dev/null
sleep 1
# re-activate on demand through D-Bus with the new environment
gdbus call --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.DBus.Properties.Get org.freedesktop.portal.Settings version >/dev/null 2>&1
