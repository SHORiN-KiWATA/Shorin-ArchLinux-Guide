#!/usr/bin/env bash
# Run after logging into GNOME as the ordinary user. Backs up existing settings.
set -euo pipefail
[[ $(id -u) -ne 0 ]] || { echo 'Run inside the ordinary GNOME user session.' >&2; exit 1; }
[[ ${XDG_SESSION_TYPE:-} == wayland ]] || { echo 'Log into GNOME Wayland first.' >&2; exit 1; }
[[ -n ${DBUS_SESSION_BUS_ADDRESS:-} ]] || { echo 'No session D-Bus; do not run through root/chroot.' >&2; exit 1; }
profile=${1:-video-2025}
[[ $profile == video-2025 || $profile == project-current ]] || exit 1
skill_dir=$(cd -- "$(dirname -- "$0")/.." && pwd)
for cmd in gsettings dconf xdg-user-dirs-update; do command -v "$cmd" >/dev/null; done
backup=$(mktemp -d "$HOME/shorin-settings-backup.XXXXXX")
dconf dump / > "$backup/dconf.ini"
for f in .zshrc .config/ghostty/config .config/ghostty/themes/catppuccin-frappe.conf; do
  if [[ -f "$HOME/$f" ]]; then mkdir -p "$backup/$(dirname "$f")"; cp -- "$HOME/$f" "$backup/$f"; fi
done
mkdir -p "$HOME/.config/ghostty/themes"
cp -- "$skill_dir/assets/catppuccin-frappe.conf" "$HOME/.config/ghostty/themes/catppuccin-frappe.conf"
cat > "$HOME/.config/ghostty/config" <<'EOF'
theme = catppuccin-frappe
window-decoration = none
background-opacity = 0.8
font-family = Adwaita Mono
font-size = 15
EOF
if [[ $profile == video-2025 ]]; then
  gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:'
  cat > "$HOME/.zshrc" <<'EOF'
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
eval "$(starship init zsh)"
EOF
fi
LANG=en_US.UTF-8 xdg-user-dirs-update
printf 'Settings backup: %s\n' "$backup"
printf '%s\n' 'Next: configure GNOME extensions, wallpaper, input method, snapshot tool and optional modules following SKILL.md.'
printf '%s\n' 'The Starship preset and exact wallpaper were not identified. Visual matching is pending.'
