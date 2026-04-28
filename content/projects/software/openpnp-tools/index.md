---
Title: "openpnp-tools — CLI Toolkit for OpenPnP"
Tags: [electronics, software, foss]
cover:
  image: "feeder-map.png"
  relative: true
editPost:
    URL: "https://www.github.com/laenzlinger/openpnp-tools"
    Text: "Visit Github Repository ↗"
    appendFilePath: false
weight: 25
---

A CLI toolkit that bridges [KiCad](https://www.kicad.org/) PCB design and
[OpenPnP](https://openpnp.org/) pick-and-place machine operation — built to streamline the
workflow on my [Lumen-PNP pick-and-place machine](/projects/electronic-prototyping/).

<!--more-->

Managing the handoff between KiCad and OpenPnP involves a lot of manual XML editing —
creating board files, mapping footprints to packages, assigning parts to feeder slots,
and keeping everything in sync across PCB revisions. **openpnp-tools** automates this
entire workflow.

## What it does

- **`generate`** — reads a KiCad position CSV and produces an OpenPnP board XML with
  remapped package names and auto-detected fiducials
- **`ensure-parts`** — creates missing parts and packages in the OpenPnP configuration
  with correct heights from a shared package map
- **`assign`** — loads a per-project feeder allocation CSV into `machine.xml`, setting
  tape type, part pitch, and tape width automatically
- **`map`** — generates a self-contained HTML page visualizing feeder positions, board
  outlines, part counts, and missing feeders

## Workflow

A typical session after a PCB revision:

```bash
make pnp          # export positions from KiCad, generate board XML, ensure parts
make feeders      # assign parts to feeder slots in machine.xml
make feeder-map   # visualize the setup
```

Switching between projects is a single command — `make feeders` reconfigures all feeder
slots for the active board.

## Package map

A single CSV file (`~/.openpnp2/openpnp-package-map.csv`) maps KiCad footprints to
OpenPnP packages with metadata like component height, tape type, part pitch, and tape
width. This is shared across all projects, so adding a new footprint once makes it
available everywhere.

## Built with

- [Go](https://go.dev/)
- [Cobra](https://github.com/spf13/cobra) for the CLI
- Self-contained HTML/CSS/JS for the feeder map visualization

Licensed under GPL-3.0-or-later, aligned with OpenPnP.
