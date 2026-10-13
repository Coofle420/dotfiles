#!/usr/bin/env bash
# Run as: sudo bash ~/rice/setup-system.sh   (CachyOS kernel + gaming tuning + debloat + zsh)
set -uo pipefail
[ "$EUID" -eq 0 ] || { echo "run with sudo"; exit 1; }
USER_NAME=${SUDO_USER:-tree}
cp -n /etc/pacman.conf /etc/pacman.conf.pre-cachy
cp -n /etc/default/grub /etc/default/grub.pre-cachy

echo "== 1/6 CachyOS repos (appended LAST so Artix packages always win)"
pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com && pacman-key --lsign-key F3B607488DB35A47 || exit 1
B=https://mirror.cachyos.org/repo/x86_64/cachyos
pacman -U --noconfirm --needed "$B/cachyos-keyring-20240331-1-any.pkg.tar.zst" \
  "$B/cachyos-mirrorlist-27-1-any.pkg.tar.zst" "$B/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst" || exit 1
sed -i 's/\$arch_v3/x86_64_v3/' /etc/pacman.d/cachyos-v3-mirrorlist
grep -q '^\[cachyos-v3\]' /etc/pacman.conf || cat >> /etc/pacman.conf <<'EOC'

[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
EOC
grep -qE '^Architecture\s*=.*x86_64_v3' /etc/pacman.conf || sed -i -E 's/^Architecture\s*=.*/Architecture = x86_64 x86_64_v3/' /etc/pacman.conf
grep -E '^Architecture' /etc/pacman.conf
pacman -Sy

echo "== 2/6 Kernel (12700KF = x86-64-v3 build)"
pacman -S --noconfirm --needed linux-cachyos linux-cachyos-headers || exit 1

echo "== 3/6 Gaming packages"
pacman -S --noconfirm --needed gamemode lib32-gamemode mangohud lib32-mangohud gamescope \
  ananicy-cpp cachyos-ananicy-rules zramen zramen-dinit zsh starship \
  zsh-autosuggestions zsh-syntax-highlighting ttf-jetbrains-mono-nerd

echo "== 4/6 Tuning (sysctl, zram, ananicy, ntsync, THP, io schedulers)"
cat > /etc/sysctl.d/99-cachy-gaming.conf <<'EOS'
vm.swappiness = 100
vm.vfs_cache_pressure = 50
vm.dirty_bytes = 268435456
vm.dirty_background_bytes = 67108864
vm.dirty_writeback_centisecs = 1500
vm.page-cluster = 0
kernel.nmi_watchdog = 0
kernel.unprivileged_userns_clone = 1
kernel.kptr_restrict = 2
net.core.netdev_max_backlog = 4096
net.ipv4.tcp_congestion_control = bbr
net.core.default_qdisc = fq
fs.file-max = 2097152
vm.max_map_count = 2147483642
EOS
echo ntsync > /etc/modules-load.d/ntsync.conf
echo 'tcp_bbr' > /etc/modules-load.d/bbr.conf
cat > /etc/udev/rules.d/60-ioschedulers.rules <<'EOS'
ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
EOS
cat > /etc/dinit.d/ananicy-cpp <<'EOS'
type = process
command = /usr/bin/ananicy-cpp start
restart = true
depends-on = boot-fs-ready
EOS
ls /etc/dinit.d/boot-fs-ready >/dev/null 2>&1 || sed -i '/depends-on/d' /etc/dinit.d/ananicy-cpp
for s in ananicy-cpp zramen; do dinitctl enable "$s" 2>&1 || ln -sf "../$s" /etc/dinit.d/boot.d/"$s"; done
sysctl --system >/dev/null 2>&1

echo "== 5/6 GRUB (keep stock kernel as fallback)"
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT='"'"'quiet nowatchdog amd_pstate=active mitigations=auto split_lock_detect=off'"'"'/' /etc/default/grub
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=3/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "== 6/6 Debloat (each removal is independent; anything still needed is skipped)"
BLOAT="xf86-video-ati xf86-video-dummy xf86-video-fbdev xf86-video-intel xf86-video-nouveau xf86-video-sisusb xf86-video-vesa xf86-video-voodoo xf86-video-amdgpu xf86-input-vmmouse vulkan-intel libva-intel-driver b43-fwcutter dmraid mdadm-dinit lvm2-dinit jfsutils f2fs-tools nbd nfs-utils-dinit cups-dinit print-manager avahi-dinit modemmanager net-snmp libesmtp librabbitmq-c librdkafka mongo-c-driver hiredis libmaxminddb libdbi s-nail ecryptfs-utils wacomtablet falkon kgpg kwalletmanager kfind keditbookmarks plasma-welcome plasma-browser-integration sddm-kcm kmenuedit ocean-sound-theme oxygen-sounds oxygen xcursor-premium artix-plasma-splash texinfo cronie-dinit haveged-dinit xorg-xinit"
for p in $BLOAT; do pacman -Qq "$p" >/dev/null 2>&1 && { pacman -Rns --noconfirm "$p" >/dev/null 2>&1 && echo "removed $p" || echo "kept   $p (needed by something)"; }; done
pacman -Qdtq 2>/dev/null | xargs -r pacman -Rns --noconfirm
pacman -Scc --noconfirm >/dev/null

echo "== zsh default shell"
chsh -s /usr/bin/zsh "$USER_NAME"
sudo -u "$USER_NAME" bash -c '[ -f ~/.config/starship.toml ] || starship preset catppuccin-powerline -o ~/.config/starship.toml'

echo; echo "DONE. Reboot, pick the linux-cachyos entry in GRUB (stock 'linux' stays as fallback)."
