# Sourced by SDDM's wayland-session wrapper (login shell) before Mango starts
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/bus"
export MOZ_ENABLE_WAYLAND=1
export ELECTRON_OZONE_PLATFORM_HINT=auto
export SDL_VIDEODRIVER=wayland,x11
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME=kde
