---
name: shorin-arch-install
description: Install x86_64 UEFI Arch Linux with the GNOME workflow from Shorin's 2025 Bilibili guide, reconcile current project changes, configure matching desktop features and Linux QQ Wayland fixes, and verify results. Use for Arch ISO installation or continuing this installation after reboot, through OpenCode or another agent with shell access.
---

# Shorin Arch installation

Read this file as operating instructions. This portable skill needs Linux shell access, not a particular model, MCP or paid API. It does not make a chat-only agent able to control hardware.

## Source and fidelity contract

Read [source-lock.json](references/source-lock.json) and [source-audit.md](references/source-audit.md) first. The two supplied videos are a 2025 **GNOME** install guide and a 2026 **QQ Wayland fix** demo. Do not substitute Niri/Hyprland/KDE or the latest author dotfiles for the 2025 desktop.

Default profile is `video-2025`. Read [video-2025-original.md](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide/blob/2db97dde40038b79f6a56a8306b1da1b86ff1c20/Archlinux%2BGnome%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE.md) by relevant heading. It is the author's video-era document, not a full transcript. Source manuals are linked rather than duplicated in this skill. Pinned upstream sources are listed in [source-index.md](references/source-index.md). Read them using the agent’s network tools, or use the corresponding files under `wiki/` in a full checkout. Use `project-current` only when the user chooses that edition, preserving the distinction: `/boot` + Timeshift versus `/efi` + Snapper. Read [compatibility.md](references/compatibility.md) before running old commands; announce any needed corrections rather than silently mixing editions.

The exact 2025 wallpaper, GNOME extension dumps, complete extension versions and Starship preset were not supplied or identified. Recreate documented functions and known settings, record pending assets, and perform screenshot comparison if references are available. **Never claim identical UI or finished installation from package installation alone.** A current preview is not evidence of the 2025 video appearance.

## Route by environment

1. **Preparation**: explain ISO/USB/UEFI and Windows space allocation using the tutorial. Do not change the current computer's partitions merely because this skill was loaded.
2. **Arch ISO Live**: inspect hardware and mount tree; connect network; enlarge `/run/archiso/cowspace` only after checking RAM and tmpfs. Preserve ISO/media and all disks except the explicitly selected install target.
3. **Installed Arch / TTY**: finish drivers, snapshot tools and desktop system services. Do not rerun the format phase.
4. **Ordinary GNOME Wayland session**: configure user settings, input method, extensions and QQ. `gsettings`, user PipeWire and AUR builds belong to the ordinary user/session, not chroot/root.
5. **Verification**: distinguish base boot, desktop functionality, requested advanced functions, and visual comparison. Report pending items honestly.

## Live installation

Read [agent-workflow.md](references/agent-workflow.md), then:

```bash
python scripts/install.py inspect
python scripts/install.py plan --config install.json > reviewed-plan.sh
```

Resolve `scripts/` relative to this skill directory. Copy `assets/install.example.json` to `install.json` and fill actual observations, including exact model/serial/byte size, CPU/GPU, swap size and requested modules. The deliberately invalid example prevents accidental installation. Do not put passwords or API keys in config or chat.

The bundled deterministic runner supports **erasing one whole dedicated disk**. It checks Linux/x86_64/UEFI/archiso/root, device identity, mounts, active swaps and device holders. It resolves packages before touching partitions. It creates GPT + ESP + Btrfs (`@`, `@home`, optional `@swap`), installs GRUB/NetworkManager/ZRAM/GNOME and copies this skill/config under `/root/shorin-arch-install` for continuation. It never automatically reboots.

If the user intends dual boot **on the same disk**, reuse of an ESP, encryption, LVM/RAID, ARM, BIOS boot, or retaining any partition on the target disk, do not run this whole-disk runner. Use the documented manual branch with the agent performing inspected partition-specific commands. Confirm only destructive changes not already authorized in context; do not guess partition names or repeat approvals for unchanged scope.

For the dedicated disk flow, show the concrete plan and ask the user to enter the runner's exact erase token locally:

```bash
python scripts/install.py apply --config install.json
```

The user enters passwords through local `passwd` prompts. Record completion and copy useful non-secret logs to the installed disk. On failure, inspect the last command and mounted state. The `/run/shorin-install-*` marker intentionally blocks automatic reformat retries during the same boot. After a Live reboot, inspect existing filesystem contents before any new `apply`; the marker is not a cross-reboot lock. Recover the partial install without formatting; consult manual steps. No destructive retry loops.

## Post-reboot and desktop completion

Read [desktop-match.md](references/desktop-match.md). Ensure internet and normal user sudo work. Copy the root-persisted skill to a location readable by the ordinary user, or load the user's supplied copy again. Finish source-specific snapshot setup, multilib, AUR helper, fonts/hardware drivers, software, optional KVM and terminal shell choice. The runner's core packages do not replace these steps.

Inside the normal user's GNOME Wayland terminal:

```bash
bash scripts/session.sh video-2025
```

This applies known terminal parameters and removes the close button as documented, backing up existing dconf/terminal/zsh files. Use `project-current` argument for that profile; it does not install current author dotfiles. Install and configure the documented GNOME extensions after checking exact extension IDs and compatibility with the installed shell version; do not disable compatibility checks or guess UUIDs. Preserve conflicting layout choices and do not enable all alternative extensions together.

Read [linuxqq-wayland-fix.md](references/linuxqq-wayland-fix.md), review the current AUR PKGBUILD, install native/AppImage QQ and `linuxqq-wayland-fix-git` through ordinary-user `paru` or `yay`. Completely exit QQ, launch **QQ（Wayland修复版）**, run `--doctor`, then test clipboard both ways, screenshots, and an actual screen-share call. Flatpak QQ is outside upstream support.

## Optional functions and final acceptance

For requested virtualization/passthrough read [advanced.md](references/advanced.md). Identify host and guest GPUs plus IOMMU groups before binding anything. Keep a recovery display/TTY and never copy author's PCI IDs. A headless VM or missing Windows ISO prevents proving guest passthrough; mark it pending.

Run `bash scripts/verify.sh` on installed Arch; perform [acceptance.md](references/acceptance.md). The script is read-only and has explicit pending checks. Save `pacman -Q`, `gnome-shell --version`, enabled extensions, relevant dconf dumps, chosen assets/hashes, source SHAs and tested/pending outcomes without secrets. Only mark complete when the requested scope has passed actual checks. The distributed runner has syntax/unit/safety checks but no end-to-end Arch VM/physical install test.

## Distribution

The complete folder is the skill: preserve `scripts/`, `assets/` and `references/`. OpenCode discovers `.opencode/skills/shorin-arch-install/SKILL.md` or `~/.config/opencode/skills/shorin-arch-install/SKILL.md`. Other agents can load the same file directly when their skill discovery differs. Do not assume a universal `/install-skill` command. Attribution and licensing: [source-audit.md](references/source-audit.md).
