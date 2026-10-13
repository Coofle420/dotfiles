#!/usr/bin/env bash
# Run: sudo bash ~/rice/setup-sddm.sh  — Catppuccin Mocha SDDM theme, Mango as default session.
# Takes effect at next login/reboot; does NOT restart SDDM (that would kill your session).
set -euo pipefail
[ "$EUID" -eq 0 ] || { echo "run with sudo"; exit 1; }
pacman -S --noconfirm --needed qt6-svg qt6-declarative unzip
cp -n /etc/sddm.conf /etc/sddm.conf.pre-rice
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
curl -fL https://github.com/catppuccin/sddm/releases/latest/download/catppuccin-mocha-mauve-sddm.zip -o "$T/theme.zip"
unzip -q "$T/theme.zip" -d "$T/x"
THEME=$(find "$T/x" -name metadata.desktop -printf '%h\n' | head -1)
[ -n "$THEME" ] || { echo "theme not found in zip"; exit 1; }
rm -rf /usr/share/sddm/themes/catppuccin-mocha-mauve
cp -r "$THEME" /usr/share/sddm/themes/catppuccin-mocha-mauve
sed -i -E 's/^Current=.*/Current=catppuccin-mocha-mauve/; s/^Session=.*/Session=mango/' /etc/sddm.conf
grep -q '^InputMethod=' /etc/sddm.conf && sed -i 's/^InputMethod=.*/InputMethod=/' /etc/sddm.conf
dinitctl is-started sddm >/dev/null 2>&1 && echo "sddm is running and enabled" || dinitctl enable sddm
echo "Done. Log out or reboot to see the Catppuccin login screen (default session: mango)."
