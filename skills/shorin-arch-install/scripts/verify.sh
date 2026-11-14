#!/usr/bin/env bash
# Read-only checks; a PASS here is not proof of visual identity or real QQ calls.
set -uo pipefail
fail=0
check() { local title=$1; shift; if "$@"; then printf 'PASS %s\n' "$title"; else printf 'FAIL %s\n' "$title"; fail=1; fi; }
[[ $(uname -s) == Linux ]] || { echo 'STOP: verify on the installed Linux system'; exit 1; }
check 'Btrfs root' bash -c '[[ $(findmnt -no FSTYPE /) == btrfs ]]'
check 'Btrfs home' bash -c '[[ $(findmnt -no FSTYPE /home) == btrfs ]]'
check 'GRUB config exists' test -s /boot/grub/grub.cfg
check 'NetworkManager enabled' systemctl is-enabled --quiet NetworkManager
check 'GDM enabled' systemctl is-enabled --quiet gdm
check 'GNOME shell installed' pacman -Q gnome-shell
check 'PipeWire installed' pacman -Q pipewire wireplumber pipewire-pulse
check 'Chinese font installed' pacman -Q noto-fonts-cjk
check 'ZRAM present' bash -c 'zramctl --noheadings | grep -q zram'
if [[ $(id -u) -ne 0 && -n ${DBUS_SESSION_BUS_ADDRESS:-} ]]; then
  check 'Wayland session' bash -c '[[ ${XDG_SESSION_TYPE:-} == wayland ]]'
  check 'PipeWire active' systemctl --user is-active --quiet pipewire pipewire-pulse wireplumber
  printf '\nENABLED EXTENSIONS\n'; gnome-extensions list --enabled || true
else
  echo 'PENDING: rerun as ordinary GNOME user to check the session.'
fi
if command -v linuxqq-wayland-fix >/dev/null; then
  check 'QQ doctor' linuxqq-wayland-fix --doctor
else
  echo 'PENDING: install QQ and its Wayland fix before final acceptance.'
fi
printf '%s\n' 'PENDING MANUAL: Wi-Fi, sound, Chinese input, extensions, snapshot restore, QQ clipboard/screenshot/screenshare, screenshot comparison, requested KVM/GPU passthrough.'
exit "$fail"
