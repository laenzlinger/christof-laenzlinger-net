---
Title: "Granit — Offsite Backup Appliance"
description: "Open hardware offsite backup appliance — custom Raspberry Pi CM4 carrier board with PCIe SATA, KiCad 4-layer PCB, impedance-controlled routing. OSHWA certified."
Tags: [electronics, embedded, raspberry-pi, foss]
cover:
  image: "granit.png"
  relative: true
editPost:
    URL: "https://www.github.com/laenzlinger/granit"
    Text: "Visit Github Repository ↗"
    appendFilePath: false
weight: 5
---

An open hardware offsite backup appliance based on the Raspberry Pi CM4.
A custom carrier board with a PCIe SATA controller, Gigabit Ethernet, and a battery-backed RTC —
designed to be left at a trusted location and managed remotely.

<!--more-->

Plug in Ethernet, plug in power, done. The device receives encrypted backups over WireGuard,
spins down the disk when idle, and costs nothing to operate after the initial build.

[![OSHWA CH000031](https://img.shields.io/badge/OSHWA-CH000031-blue)](https://certification.oshwa.org/ch000031.html)

## Key Specs

- **ASM1061** PCIe Gen 2 x1 to dual SATA III — no proprietary firmware required
- **Gigabit Ethernet** with integrated magnetics (Hanrun HR911130A)
- **DS3231 RTC** with battery backup for scheduled wake/sleep
- **12V DC input** supporting both 2.5" and 3.5" SATA drives
- **USB-C OTG** for eMMC flashing and initial backup seeding
- **Software-controlled HDD power** — GPIO-driven P-FET switching, disk only spins when needed
- **4-layer PCB** with impedance-controlled differential routing, designed in KiCad 10
- **Hammond 1455 aluminium enclosure**
- **~€125 BOM cost** — pays for itself in under two years vs. cloud backup

## PCB Design

The board is a 4-layer design fabricated at JLCPCB with 1oz copper on all layers:

- **Top layer:** Components, PSU routing, signal traces
- **Inner layers:** Unbroken GND planes for signal integrity
- **Bottom layer:** Power distribution (12V, 5V, 3.3V)

High-speed interfaces use impedance-controlled differential pairs:
- **PCIe:** 100Ω differential to ASM1061 SATA controller
- **SATA:** 100Ω differential with AC coupling capacitors
- **Gigabit Ethernet:** 100Ω differential to RJ45 with magnetics
- **USB:** 90Ω differential for OTG port

Power routing uses dedicated netclasses sized per IPC-2221 (3mm tracks for 12V,
2.5mm for 5V) with parallel vias at layer transitions.

## Software

The device runs a minimal Raspberry Pi OS image with:
- **WireGuard** — encrypted tunnel to home network
- **rclone** — incremental sync from NAS
- **Automated wake/sleep cycle** — RTC wakes at configured hour, syncs, shuts down
- **Prometheus metrics** — remote-write health data (disk usage, sync status, temperature)
- **Ansible-provisioned** — entire configuration reproducible from code

Image built via pi-gen, all services configured via Ansible playbook.

## Roadmap

- **v0.3** — First production run (current, assembled on my own pick-and-place machine)
- **v0.4** — Fix wake/shutdown latch, barrel jack swap, DF40C alignment bosses
- **v1.0** — Validated design with custom OS image and full documentation
- **Future** — Investigating RISC-V SoM for a fully blob-free variant

## Documentation

Hardware documentation is [auto-generated via CI](/projects/software/hugo-kicad-site/):
[laenzlinger.github.io/granit](https://laenzlinger.github.io/granit/)

Licensed under [CERN Open Hardware Licence v2 — Permissive](https://ohwr.org/cern_ohl_p_v2.txt).

## Context

This project grew out of my [Home NAS Infrastructure](/projects/hardware/nas-infra/) — the offsite backup
currently runs on a CM5 with a USB-to-SATA cable. Granit replaces that with a dedicated board
that's reliable enough to leave at a remote location unattended.
