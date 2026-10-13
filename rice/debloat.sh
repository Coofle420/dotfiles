#!/usr/bin/env bash
# Debloat Artix + install KDE Discover.
#   Preview only (no root, changes nothing):  bash ~/rice/debloat.sh --dry
#   Do it:                                    sudo bash ~/rice/debloat.sh
# Each tier shows the exact packages and asks before removing anything.
set -uo pipefail

DRY=0; [ "${1:-}" = "--dry" ] && DRY=1
if [ "$DRY" = 0 ] && [ "$EUID" -ne 0 ]; then echo "Run with sudo:  sudo bash $0   (or preview with: bash $0 --dry)"; exit 1; fi

# --- packages that would be removed only as a side effect but are worth keeping ---
KEEP_EXPLICIT=(noto-fonts-emoji kimageformats vulkan-tools mesa-utils smartmontools ddcutil i2c-tools)

# --- tier 1: Artix defaults + dead weight --------------------------------------------
T1=(artix-desktop-presets artix-dark-theme artix-backgrounds artix-gtk-presets artix-qt-presets artix-icons
    artix-grub-theme artix-sddm-theme artix-wallpapers
    amd-ucode          # you have an Intel CPU
    alsa-firmware      # firmware for ancient sound cards
    linux-headers linux-cachyos-headers   # only needed for DKMS modules (also frees llvm/clang/pahole)
    ttf-droid ttf-inconsolata bun zip)
# --- tier 2: the Plasma desktop shell you don't use (Plasma core stays: your Qt theme needs it) ---
T2=(plasma-desktop kdeplasma-addons plasma-nm plasma-pa plasma-systemmonitor plasma-disks powerdevil bluedevil
    kscreen kinfocenter kmenuedit kgamma kwrited systemsettings modemmanager)
# --- tier 3: extras ---------------------------------------------------------------------
T3=(dhclient dhcpcd-dinit rsync-dinit net-tools cmake)

installed_only() { local o=(); for p in "$@"; do pacman -Qq "$p" >/dev/null 2>&1 && o+=("$p"); done; printf '%s\n' "${o[@]}"; }

show_tier() {   # $1 name, rest = packages; prints targets, returns list in $TARGETS
  local name=$1; shift
  mapfile -t pk < <(installed_only "$@")
  [ ${#pk[@]} -eq 0 ] && { echo "   (nothing from $name is installed)"; TARGETS=""; return 1; }
  TARGETS=$(pacman -Rsp "${pk[@]}" 2>&1)
  if ! pacman -Rsp "${pk[@]}" >/dev/null 2>&1; then echo "   !! pacman refuses (dependency problem):"; echo "$TARGETS" | sed 's/^/      /'; return 1; fi
  if [ "$DRY" = 1 ]; then   # preview: hide packages the real run would mark as explicit (kept)
    keep_re=$(IFS='|'; echo "${KEEP_EXPLICIT[*]}")
    TARGETS=$(echo "$TARGETS" | tr ' ' '\n' | grep -vE "^($keep_re)-[0-9]" | tr '\n' ' ')
  fi
  echo "   would remove $(echo "$TARGETS" | wc -w) packages:"
  echo "$TARGETS" | tr ' ' '\n' | sed 's/-[0-9][^ ]*$//; s/^/      /' | paste -sd' ' | fold -s -w 100
  PKGS=("${pk[@]}"); return 0
}

confirm() { [ "$DRY" = 1 ] && return 1; read -rp "   Remove these? [y/N] " a; [[ "$a" =~ ^[Yy]$ ]]; }

echo "== keeping useful side-effect packages (marking explicit)"
if [ "$DRY" = 0 ]; then
  for p in "${KEEP_EXPLICIT[@]}"; do pacman -Qq "$p" >/dev/null 2>&1 && pacman -D --asexplicit "$p" >/dev/null && echo "   kept: $p"; done
else
  echo "   (dry run) would keep: ${KEEP_EXPLICIT[*]}"
fi

for tier in T1 T2 T3; do
  case $tier in T1) label="TIER 1 - Artix defaults and dead weight"; arr=("${T1[@]}");;
                T2) label="TIER 2 - unused Plasma desktop shell";    arr=("${T2[@]}");;
                T3) label="TIER 3 - extras (old DHCP clients, cmake, net-tools)"; arr=("${T3[@]}");; esac
  echo; echo "== $label"
  # In a real run the keep-list is already explicit, so it is excluded from the pacman -Rs target set
  if show_tier "$tier" "${arr[@]}"; then
    if confirm; then pacman -Rns --noconfirm "${PKGS[@]}" || echo "   !! removal reported an error"; fi
  fi
done

echo; echo "== leftover orphans (dependencies nothing needs any more)"
mapfile -t ORPH < <(pacman -Qdtq 2>/dev/null)
if [ ${#ORPH[@]} -gt 0 ]; then
  printf '   %s\n' "${ORPH[@]}"
  if [ "$DRY" = 0 ] && read -rp "   Remove these orphans? [y/N] " a && [[ "$a" =~ ^[Yy]$ ]]; then pacman -Rns --noconfirm "${ORPH[@]}"; fi
else echo "   none"; fi

if [ "$DRY" = 0 ]; then
  echo; echo "== dangling dinit links (services that no longer exist)"
  for l in /etc/dinit.d/boot.d/*; do [ -e "$l" ] || { echo "   removing $l"; rm -f "$l"; }; done

  echo; echo "== package cache"
  if command -v paccache >/dev/null; then paccache -rk1; else yes | pacman -Sc >/dev/null 2>&1 || true; fi
  echo "   cache now: $(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1)"

  echo; echo "== KDE Discover"
  pacman -S --needed --noconfirm discover packagekit packagekit-qt6 flatpak-kcm || echo "   !! Discover install reported an error"

  echo; echo "== regenerating GRUB config (amd-ucode may have been removed; GRUB's menu references it)"
  grub-mkconfig -o /boot/grub/grub.cfg

  echo; echo "== done. disk used on /: $(df -h / | awk 'NR==2{print $3" of "$2}')"
  echo "Reboot recommended."
fi
