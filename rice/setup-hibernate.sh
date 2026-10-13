#!/usr/bin/env bash
# Set up hibernation on btrfs: 32 GB swapfile in its own subvolume, resume hook, kernel resume= params.
# Run:  sudo bash ~/rice/setup-hibernate.sh      (then REBOOT, then follow the test steps it prints)
set -euo pipefail
[ "$EUID" -eq 0 ] || { echo "Run with sudo:  sudo bash $0"; exit 1; }

SIZE=32g                      # about your RAM (31 GiB) so the whole memory image always fits
STAMP=$(date +%F-%H%M)
ROOT_DEV=$(findmnt -no SOURCE / | sed 's/\[.*//')
ROOT_UUID=$(findmnt -no UUID /)
[ "$(findmnt -no FSTYPE /)" = btrfs ] || { echo "Root is not btrfs; this script is for btrfs only"; exit 1; }

free_gb=$(df --output=avail -BG / | tail -1 | tr -dc 0-9)
[ "$free_gb" -gt 60 ] || { echo "Only ${free_gb} GB free; need > 60 GB"; exit 1; }
command -v mkinitcpio >/dev/null || { echo "mkinitcpio not found"; exit 1; }

echo "== backups"
cp -a /etc/fstab               "/etc/fstab.pre-hibernate-$STAMP"
cp -a /etc/mkinitcpio.conf     "/etc/mkinitcpio.conf.pre-hibernate-$STAMP"
cp -a /etc/default/grub        "/etc/default/grub.pre-hibernate-$STAMP"
echo "   saved fstab, mkinitcpio.conf and grub config with suffix .pre-hibernate-$STAMP"

echo "== 1/5 swap subvolume (@swap) and swapfile ($SIZE)"
if [ ! -d /swap ]; then mkdir /swap; fi
if ! mountpoint -q /swap; then
  TOP=$(mktemp -d); mount -o subvolid=5 "$ROOT_DEV" "$TOP"
  [ -d "$TOP/@swap" ] || btrfs subvolume create "$TOP/@swap"
  umount "$TOP"; rmdir "$TOP"
  grep -q '/swap ' /etc/fstab || echo "UUID=$ROOT_UUID /swap btrfs subvol=@swap,noatime 0 0" >> /etc/fstab
  mount /swap
fi
if [ ! -f /swap/swapfile ]; then btrfs filesystem mkswapfile --size "$SIZE" /swap/swapfile; fi
chmod 600 /swap/swapfile
grep -q '/swap/swapfile' /etc/fstab || echo "/swap/swapfile none swap defaults,pri=1 0 0" >> /etc/fstab
swapon --show=NAME | grep -qx /swap/swapfile || swapon -p 1 /swap/swapfile
swapon --show

echo "== 2/5 resume offset"
OFFSET=$(btrfs inspect-internal map-swapfile -r /swap/swapfile)
[ -n "$OFFSET" ] || { echo "could not read the swapfile offset"; exit 1; }
echo "   resume=UUID=$ROOT_UUID  resume_offset=$OFFSET"

echo "== 3/5 kernel command line (applies to BOTH kernels)"
python3 -I - "$ROOT_UUID" "$OFFSET" <<'PY'
import re, sys
uuid, off = sys.argv[1:3]
p = "/etc/default/grub"; s = open(p).read()
m = re.search(r"(?m)^GRUB_CMDLINE_LINUX_DEFAULT=(['\"])(.*?)\1", s)
assert m, "GRUB_CMDLINE_LINUX_DEFAULT not found"
args = [a for a in m.group(2).split() if not a.startswith(("resume=", "resume_offset="))]
args += [f"resume=UUID={uuid}", f"resume_offset={off}"]
s = s[:m.start()] + "GRUB_CMDLINE_LINUX_DEFAULT='" + " ".join(args) + "'" + s[m.end():]
open(p, "w").write(s)
print("   " + " ".join(args))
PY

echo "== 4/5 initramfs: add the 'resume' hook (before 'filesystems') and rebuild"
python3 -I - <<'PY'
import re
p = "/etc/mkinitcpio.conf"; s = open(p).read()
m = re.search(r"(?m)^HOOKS=\((.*?)\)", s)
hooks = m.group(1).split()
if "resume" not in hooks:
    assert "filesystems" in hooks and "udev" in hooks, "unexpected hooks list: " + " ".join(hooks)
    hooks.insert(hooks.index("filesystems"), "resume")
    s = s[:m.start()] + "HOOKS=(" + " ".join(hooks) + ")" + s[m.end():]
    open(p, "w").write(s)
print("   HOOKS=(" + " ".join(hooks) + ")")
PY
mkinitcpio -P

echo "== 5/5 regenerate GRUB config"
grub-mkconfig -o /boot/grub/grub.cfg

echo
echo "== done. Now REBOOT, then verify:"
echo "   cat /proc/cmdline | tr ' ' '\\n' | grep resume      (2 lines expected)"
echo "   swapon --show                                        (zram + /swap/swapfile)"
echo "   busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager CanHibernate   (expect: s \"yes\")"
echo "Undo: restore the .pre-hibernate-$STAMP files, run 'mkinitcpio -P' and 'grub-mkconfig -o /boot/grub/grub.cfg'."
