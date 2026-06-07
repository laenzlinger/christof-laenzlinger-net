---
Title: FOSS Development Environment
description: "Arch Linux development setup with Sway, foot, and LazyVim — a minimal, productive environment for open source work."
cover:
  image: "screenshot.png"
  relative: true
Tags: [linux, software, foss]
---

All my personal development machines run Arch Linux. The goal: a single, reproducible environment
that works identically across different hardware — fast, minimal, and entirely under my control.
<!-- more -->

## Why FOSS All the Way Down

I want to understand and own my tools. When something breaks, I want to fix it — not file a
support ticket and wait. When something annoys me, I want to change it. A fully open-source
stack makes this possible at every layer, from the window manager to the editor.

Arch Linux is the foundation because it stays out of the way. No preconfigured desktop, no
bundled applications, no opinions about how I should work. I install exactly what I need and
configure it exactly how I want. The rolling-release model means I always have current software
without distribution-upgrade migrations.

## Multi-Machine Setup

I run the same environment on two machines:

- **gibson** — ThinkPad X1 Carbon Gen 12 (Intel, daily driver)
- **fender** — MacBook Pro 16" M1 (Apple Silicon via [Asahi ALARM](/projects/software/asahi-alarm-encrypted/))

All configuration lives in a single [chezmoi](https://www.chezmoi.io) dotfiles repository.
Machine-specific differences — package lists, display scaling, kernel — are handled via
templates. A change made on one machine is a `git pull` away on the other.

This reproducibility is the point. If a machine dies tomorrow, I can have my full environment
running on new hardware in under an hour.

## Desktop: Sway

After meeting Michael Stapelberg, the author of the [i3 window manager](https://i3wm.org),
at a Go meetup in Zurich, I adopted tiling window managers and never looked back. Every window
has a purpose and a place — no overlapping, no hunting for buried windows.

When Wayland matured enough, I moved to [Sway](https://swaywm.org). It's a drop-in replacement
for i3 on Wayland with proper HiDPI support, per-monitor scaling, and no screen tearing.

The sway config is split into modular files: keybindings, floating rules, autostart, display
layout. Background services (clipboard manager, notification daemon, idle lock) run as systemd
user units rather than `exec` lines — they start reliably and can be managed independently.

## Status Bar: Waybar

[Waybar](https://github.com/Alexays/Waybar) shows system state at a glance. Custom scripts
report network status (including VPN), CPU, memory, battery health, backup freshness, and
pending updates. Tooltips reveal detail — top processes, connection info — without needing
to open a terminal.

Floating overlays (KeePassXC, Bluetooth, audio patchbay) toggle from waybar clicks using a
consistent pattern: check if visible, kill if yes, launch if no.

## Launcher: Rofi

[Rofi](https://github.com/davatorium/rofi) is the interface for everything that isn't a
persistent window. App launcher, clipboard history, file search, WiFi network picker,
calculator, USB eject, and a keybinding cheatsheet — all through the same consistent UI.

Every rofi binding uses the toggle pattern (`pkill rofi || rofi ...`), so the same key opens
and closes it. This makes the interaction predictable: one key, one action.

## Terminal: foot

After years with Alacritty and then WezTerm, I settled on
[foot](https://codeberg.org/dnkl/foot) — a lightweight Wayland-native terminal. It starts
instantly, handles HiDPI correctly, and does one thing well: render text fast.

A custom spawn script inherits the working directory from the last active terminal, so new
windows open where I'm already working.

## Shell: Zsh + Starship

Zsh with a minimal plugin set: syntax highlighting, autosuggestions, and transient prompts
(previous commands collapse to a clean line). Managed by
[Antidote](https://getantidote.github.io) — pure zsh, no framework overhead.

[Starship](https://starship.rs) provides the prompt: current directory, git branch/status,
active language runtime. It appears only when relevant — a clean prompt in a non-git directory,
rich context inside a project.

## Colors: Tinted Theming

I switch between a dark theme (darktooth) and a light theme (gruvbox-light) automatically
based on sun position via [darkman](https://darkman.whynothugo.nl). Every application follows
along — terminal, editor, status bar, launcher, browser, notification center.

[Tinty](https://github.com/tinted-theming/tinty) orchestrates the switch. A single theme
change triggers hooks that regenerate color files for each application. All colors derive from
one base16 palette, so everything stays visually coherent without manual per-app configuration.

## Font: MesloLGS Nerd Font

[MesloLGS Nerd Font](https://www.nerdfonts.com) everywhere — terminal, editor, status bar.
One font across the entire environment means consistent character widths, icon rendering, and
no surprises when switching contexts.

## Editor: Neovim with LazyVim

I keep coming back to vim. After years of maintaining a hand-crafted config, I switched to
[LazyVim](https://www.lazyvim.org) — a curated Neovim distribution that provides sensible
defaults for LSP, completion, file navigation, and git integration. I still customize it,
but I no longer maintain the scaffolding.

The key advantage over GUI editors: it works identically over SSH, in containers, and across
architectures. The same muscle memory applies whether I'm editing locally or on a remote
server.

## Security

The environment is encrypted at rest (LUKS full disk encryption on both machines). SSH keys
live in a GPG agent with hardware-backed key storage — one agent for both GPG signing and SSH
authentication.

Secrets in the dotfiles repository are encrypted with [sops](https://github.com/getsops/sops),
so the repo stays public while credentials remain private. Passwords live in
[KeePassXC](https://keepassxc.org), accessible via a keyboard shortcut from any workspace.
