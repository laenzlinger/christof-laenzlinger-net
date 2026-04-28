---
Title: "Granit — Offsite Backup Appliance"
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

Key specs:

- **ASM1061** PCIe Gen 2 x1 to dual SATA III — no proprietary firmware required
- **Gigabit Ethernet** with integrated magnetics (Hanrun HR911130A)
- **DS3231 RTC** with battery backup for scheduled wake/sleep
- **12V DC input** supporting both 2.5" and 3.5" SATA drives
- **USB-C OTG** for eMMC flashing and initial backup seeding
- **4-layer PCB** with impedance-controlled differential routing, designed in KiCad 10
- **~€125 BOM cost** — pays for itself in under two years vs. cloud backup

Hardware documentation is [auto-generated via CI](/projects/hugo-kicad-site/):
[laenzlinger.github.io/granit](https://laenzlinger.github.io/granit/)

Licensed under [CERN Open Hardware Licence v2 — Permissive](https://ohwr.org/cern_ohl_p_v2.txt).

This project grew out of my [Home NAS Infrastructure](/projects/nas-infra/) — the offsite backup
currently runs on a CM5 with a USB-to-SATA cable. Granit replaces that with a dedicated board.
