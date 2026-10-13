#!/usr/bin/env bash
# Install virt-manager + QEMU/KVM + libvirt on Artix (dinit).
# Run:  sudo bash ~/rice/install-virt.sh
# Then log out and back in once (group membership), and open "Virtual Machine Manager".
set -uo pipefail
[ "$EUID" -eq 0 ] || { echo "Run with sudo:  sudo bash $0"; exit 1; }
USER_NAME=${SUDO_USER:-tree}

echo "== 1/4 packages"
# iptables-nft replaces the legacy 'iptables' package; pacman will ask you to confirm that swap.
pacman -S --needed virt-manager qemu-desktop libvirt libvirt-dinit dnsmasq edk2-ovmf swtpm dmidecode iptables-nft \
  || { echo "!! install failed or was cancelled"; exit 1; }

echo "== 2/4 groups for $USER_NAME"
for g in libvirt kvm; do getent group "$g" >/dev/null && usermod -aG "$g" "$USER_NAME" && echo "   added to $g"; done

echo "== 3/4 dinit services provided by libvirt-dinit"
pacman -Ql libvirt-dinit | grep -E '/etc/dinit.d/[^/]+$' | awk '{print $2}' | sed 's|.*/||' | sort -u > /tmp/virt-services.txt
cat /tmp/virt-services.txt | sed 's/^/   found: /'
while read -r svc; do
  [ -n "$svc" ] && dinitctl enable "$svc" 2>&1 | sed "s/^/   enable $svc: /"
done < /tmp/virt-services.txt
for svc in libvirtd virtlogd virtlockd; do
  [ -e "/etc/dinit.d/$svc" ] && dinitctl start "$svc" 2>&1 | sed "s/^/   start $svc: /"
done

echo "== 4/4 default NAT network"
virsh net-autostart default 2>&1 | sed 's/^/   /'
virsh net-start default 2>&1 | sed 's/^/   /'

echo
echo "Done. Log out and back in so your new groups apply, then start 'Virtual Machine Manager'."
echo "Check:  virsh -c qemu:///system list --all     (should print an empty table, not an error)"
