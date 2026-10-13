#!/usr/bin/env bash
# Back up the config files on this machine so they can be moved to another distro (Void).
# Needs no root. Run:  bash ~/rice/backup-configs.sh
# Output: ~/void-migration/configs-<date>.tar.zst  +  package/service lists + MANIFEST.txt
# Left OUT on purpose: logins/session data (Discord, Helium profile, Cider, Signal, Fluxer, gh token, gnupg,
# ssh keys, Claude Code), caches, Steam games, shell history. See the end of this script's output.
set -uo pipefail

STAMP=$(date +%F)
OUT="$HOME/void-migration"
STAGE="$OUT/stage-$STAMP"
ARCHIVE="$OUT/configs-$STAMP.tar.zst"
rm -rf "$STAGE"; mkdir -p "$STAGE/home" "$STAGE/system" "$STAGE/lists"

echo "== 1/5 home dotfiles and ~/.config"
cd "$HOME"
for f in .zshrc .zprofile .bashrc .bash_profile .bash_logout .gitconfig .gtkrc-2.0 .gtkrc-2.0-kde4 .face .face.icon .icons; do
  [ -e "$f" ] && cp -a --parents "$f" "$STAGE/home/"
done
# ~/.config minus app data / secrets / caches
rsync -a --prune-empty-dirs \
  --exclude='/discord' --exclude='/net.imput.helium' --exclude='/sh.cider.genten' --exclude='/Signal' --exclude='/fluxer' \
  --exclude='/gh' --exclude='/zoom*' --exclude='/pulse' --exclude='/Proton*' --exclude='/proton*' --exclude='/kdeconnect' \
  --exclude='Cache' --exclude='Cache_Data' --exclude='GPUCache' --exclude='Code Cache' --exclude='logs' \
  --exclude='*.bak*' --exclude='*.sock' \
  .config/ "$STAGE/home/.config/"

echo "== 2/5 ~/.local (scripts, launchers, themes, Noctalia state) and ~/rice scripts"
for d in .local/bin .local/share/applications .local/share/icons .local/share/color-schemes .local/share/mime \
         .local/share/desktop-directories .local/share/sddm .local/share/noctalia .local/share/wavv-cider \
         .local/share/plasma_icons .local/share/qalculate .local/share/audacity; do
  [ -e "$d" ] && mkdir -p "$STAGE/home/$(dirname "$d")" && cp -a "$d" "$STAGE/home/$(dirname "$d")/"
done
# Noctalia state: only the settings file (the rest is cache, ~28 MB)
mkdir -p "$STAGE/home/.local/state/noctalia" && cp -a .local/state/noctalia/settings.toml "$STAGE/home/.local/state/noctalia/" 2>/dev/null
rsync -a --exclude='artix-skel-backup' --exclude='milkgrub-src' --exclude='milkgrub-build' --exclude='tmp' --exclude='mango-pre018-backup' \
  "$HOME/rice/" "$STAGE/home/rice/" 2>/dev/null

echo "== 3/5 system config (readable files only)"
for p in /etc/pacman.conf /etc/pacman.d/mirrorlist /etc/default/grub /etc/fstab /etc/mkinitcpio.conf /etc/sddm.conf /etc/sddm.conf.d \
         /etc/environment /etc/locale.conf /etc/locale.gen /etc/vconsole.conf /etc/hostname /etc/hosts /etc/os-release \
         /etc/sysctl.d /etc/modprobe.d /etc/modules-load.d /etc/udev/rules.d /etc/security/limits.d /etc/X11 \
         /etc/NetworkManager/conf.d /etc/NetworkManager/system-connections /etc/libvirt /etc/dinit.d /etc/local.d.disabled \
         /usr/share/sddm/themes/R1999_1 /usr/share/sddm/scripts/Xsetup /boot/grub/themes /etc/zramen /etc/ananicy.d; do
  [ -e "$p" ] && { mkdir -p "$STAGE/system$(dirname "$p")"; cp -aL "$p" "$STAGE/system$(dirname "$p")/" 2>/dev/null; rm -rf "$STAGE/system/etc/libvirt/secrets" "$STAGE/system/etc/libvirt/secret.conf"; true || echo "   (some of $p was unreadable, skipped)"; }
done
# Wi-Fi passwords are readable only by root; say so rather than pretend
[ -d "$STAGE/system/etc/NetworkManager/system-connections" ] && [ -z "$(ls -A "$STAGE/system/etc/NetworkManager/system-connections" 2>/dev/null)" ] \
  && echo "   (NetworkManager connections are root-only: not included)"

echo "== 4/5 package and service lists, hardware notes"
L="$STAGE/lists"
pacman -Qqen        > "$L/pacman-explicit-repo.txt"
pacman -Qqem        > "$L/pacman-explicit-aur-or-foreign.txt"
command -v flatpak >/dev/null && flatpak list --app --columns=application > "$L/flatpak-apps.txt" 2>/dev/null
ls /etc/dinit.d/boot.d 2>/dev/null > "$L/dinit-boot-services.txt"
ls "$HOME/.config/dinit.d/boot.d" 2>/dev/null > "$L/dinit-user-boot-services.txt"
cat /proc/cmdline   > "$L/kernel-cmdline.txt"
lsblk -f            > "$L/lsblk.txt" 2>/dev/null
lspci -nnk          > "$L/lspci.txt" 2>/dev/null
gh repo list --limit 50 > "$L/github-repos.txt" 2>/dev/null

echo "== 5/5 archive"
{
  echo "Backup made $(date) on $(hostname), $(uname -r)"
  echo; echo "== contents (top level)"; (cd "$STAGE" && find . -maxdepth 3 -mindepth 1 -type d | sort)
  echo; echo "== sizes"; du -sh "$STAGE"/* | sed "s|$STAGE/||"
} > "$STAGE/MANIFEST.txt"
tar -C "$STAGE" -I 'zstd -19 -T0' -cf "$ARCHIVE" .
echo
ls -lh "$ARCHIVE"
echo "files: $(tar -I zstd -tf "$ARCHIVE" | wc -l)"
echo
echo "NOT included (sessions/secrets/large): Discord, Helium profile, Cider, Signal, Fluxer, gh token, ~/.gnupg, ~/.ssh,"
echo "Claude Code data, Zoom config, libvirt secrets, Steam library, wallpapers (they are on GitHub: Coofle420/wallpapers), shell history."
