---
Title: FOSS Development Environment
description: "Arch Linux development setup with Sway, WezTerm, and LazyVim — a minimal, productive environment for open source work."
cover:
  image: "screenshot.png"
  relative: true
Tags: [linux, software, foss]
---

All my personal development machines run Arch Linux. This page documents my setup and configuration
for a productive development environment.
<!-- more -->
Working on open source projects requires a flexible and customizable environment. Arch Linux
provides a minimal base system that allows me to install only the packages and tools I need.

After many years of using different Linux distributions, I settled on Arch Linux for its simplicity.
I want to have control over my system and avoid unnecessary bloatware.

## Multi-Machine Setup

I run the same environment on two machines:

- **gibson** — ThinkPad X1 Carbon Gen 12 (Intel, daily driver)
- **fender** — MacBook Pro 16" M1 (Apple Silicon via [Asahi ALARM](/projects/software/asahi-alarm-encrypted/))

Both run Arch Linux with identical tooling. All configuration is managed through
[chezmoi](https://www.chezmoi.io) from a single dotfiles repository, with machine-specific
differences (package lists, display scaling, kernel) handled via templates. A change made on
one machine is a `git pull` away on the other.

## Desktop Environment

After meeting Micheal Stapelberg, the author of the [i3 window manager](https://i3wm.org)
at a golang meetup in Zurich, I decided to give it a try. Since then, I have been using
tiling window managers on my personal machines. However, after switching to Wayland,
I found [Sway](https://swaywm.org) to be a great alternative that offers similar functionality.

## Terminal Emulator

For a long time, I used [Alacritty](https://alacritty.org) as my terminal emulator. I appreciate
its stability and performance. It allows me to select text without using the mouse,
using vim-like keybindings.
However, I recently switched to [WezTerm](https://wezterm.org/index.html) for its advanced
features like image rendering or advanced navigations.

## Colors and Fonts

I am happily using [NerdFont Meslo](https://www.nerdfonts.com) as my main font across terminal
and IDE. I never had a good reason to switch to another font.

I love the base16 (and base24) color schemes and I am switching between a light and dark theme
depending on the time. This is especially useful when working in different lighting conditions.
For consistent theming across applications, I use the
[Tinted Theming](<https://github.com/tinted-theming>) system which all to automate the configuration.

## IDE

I have used numerous IDEs over the years, but I always come back to `vim` (or `neovim`). For many years,
i have configured vim to my liking, but i recently switched to [LazyVim](https://www.lazyvim.org),
which provides a great default configuration that I can further customize.
