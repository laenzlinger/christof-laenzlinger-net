---
Title: FOSS Development Environment
description: "Arch Linux development setup with Sway, WezTerm, and LazyVim — a minimal, productive environment for open source work."
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

Both run Arch Linux with identical tooling. All configuration is managed through
[chezmoi](https://www.chezmoi.io) from a single dotfiles repository, with machine-specific
differences (package lists, display scaling, kernel) handled via templates. A change made on
one machine is a `git pull` away on the other.

This reproducibility is the point. If a machine dies tomorrow, I can have my full environment
running on new hardware in under an hour.

## Desktop: Sway

After meeting Michael Stapelberg, the author of the [i3 window manager](https://i3wm.org),
at a Go meetup in Zurich, I adopted tiling window managers and never looked back. Every window
has a purpose and a place — no overlapping, no hunting for buried windows.

When Wayland matured enough, I moved to [Sway](https://swaywm.org). It's a drop-in replacement
for i3 on Wayland with proper HiDPI support, per-monitor scaling, and no screen tearing.
The configuration is almost identical to i3, so the transition was painless.

## Terminal: WezTerm

For years I used [Alacritty](https://alacritty.org) — minimal, fast, reliable. But I eventually
wanted features it deliberately doesn't offer: inline image rendering, multiplexing, and richer
text navigation.

[WezTerm](https://wezterm.org) provides all of that while remaining GPU-accelerated and
configurable in Lua. It's one of the few terminals that handles both HiDPI scaling and
Nerd Font ligatures correctly across Wayland compositors.

## Colors: Tinted Theming

I switch between a dark theme (darktooth) and a light theme (gruvbox-light) depending on
ambient lighting. This means every application needs to follow along — terminal, editor,
status bar, launcher, browser, notification center.

The [Tinted Theming](https://github.com/tinted-theming) system with
[tinty](https://github.com/tinted-theming/tinty) solves this. A single theme switch
triggers hooks that regenerate color files for each application. All colors derive from
one base16 palette, so everything stays visually coherent without manual per-app configuration.

## Font: MesloLGS Nerd Font

[MesloLGS Nerd Font](https://www.nerdfonts.com) everywhere — terminal, editor, status bar.
One font across the entire environment means consistent character widths, icon rendering, and
no surprises when switching contexts. I've never found a reason to change it.

## Editor: Neovim with LazyVim

I keep coming back to vim. After years of maintaining a hand-crafted config, I switched to
[LazyVim](https://www.lazyvim.org) — a curated Neovim distribution that provides sensible
defaults for LSP, completion, file navigation, and git integration. I still customize it,
but I no longer maintain the scaffolding.

The key advantage over GUI editors: it works identically over SSH, in containers, and across
architectures. The same muscle memory applies whether I'm editing locally or on a remote
server.
