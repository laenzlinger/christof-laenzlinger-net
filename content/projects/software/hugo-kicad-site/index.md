---
Title: "Documentation Theme for KiCad Projects"
Tags: [electronics, foss, software]
cover:
  image: "hugo-kicad-site.png"
  relative: true
  hiddenInSingle: true
editPost:
    URL: "https://www.github.com/laenzlinger/hugo-kicad-site"
    Text: "Visit Github Repository ↗"
    appendFilePath: false
weight: 7
---

A reusable Hugo theme that turns a KiCad hardware project into a polished, versioned documentation
site — with interactive viewers, auto-generated assets, and zero manual effort after initial setup.

<!--more-->

Born out of frustration with manually maintaining project pages for my open hardware designs.
Every time I tagged a release of [Granit](/projects/granit/) or the
[Open Pedalboard](/projects/pedalboard/), I had to manually update screenshots, BOMs, and download
links. hugo-kicad-site automates all of that.

## How It Works

Push your KiCad files. A reusable GitHub Actions workflow runs [KiBot](https://github.com/INTI-CMNB/KiBot)
to generate all assets, then builds a versioned Hugo site and deploys it to GitHub Pages.
Each git tag gets its own complete site — with a version picker to switch between releases.

**Live demo:** [laenzlinger.github.io/hugo-kicad-site](https://laenzlinger.github.io/hugo-kicad-site/latest/)

## Features

- **[KiCanvas](https://kicanvas.org/)** embedded viewer for interactive schematic and PCB browsing
- **Blender-rendered 3D gallery** via KiBot's `blender_export`
- **Interactive BOM** with dark mode sync
- **Interactive 3D assembly viewer** (STEP/GLB via [Online3DViewer](https://github.com/kovacsv/Online3DViewer))
- **Visual diffs** of schematic and PCB changes between releases
- **Downloads** — Gerbers, BOM, schematics, all auto-discovered from KiBot output
- **Version picker** — Read the Docs style, switch between tagged releases
- **OSHWA and license badges** in the footer
- **Custom markdown pages** for assembly guides, design notes, etc.
- **Fullscreen toggle** on all viewers, with CSS fallback for iOS
- **Dark mode** — inherited from PaperMod, synced to iBOM iframe

## Architecture

Each version is a self-contained Hugo site deployed to its own directory on GitHub Pages.
A `versions.json` file powers the version picker. The root URL redirects to `latest/`.

The theme is a Hugo module built on [PaperMod](https://github.com/adityatelange/hugo-PaperMod).
All configuration is via `hugo.yaml` params — no forking required.

## Used By

- [Granit](https://laenzlinger.github.io/granit/latest/) — CM4 offsite backup appliance
- [Open Pedalboard](https://pedalboard.github.io/pedalboard-hw/latest/) — modular guitar pedalboard

Licensed under [GPL-3.0-or-later](https://www.gnu.org/licenses/gpl-3.0.html).
