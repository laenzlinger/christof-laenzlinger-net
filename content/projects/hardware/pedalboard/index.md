---
Title: Pedalboard Hard and Software Platform
Tags: [electronics, embedded, raspberry-pi]
cover:
  image: "pedalboard.png"
  relative: true
editPost:
    URL: "https://www.github.com/pedalboard"
    Text: "Visit Github Organisation ↗"
    appendFilePath: false
weight: 10
---

A showcase for the combination of many different engineering skills:
My custom pedalboard hard and software platform for managing guitar effects pedals during live performances.

<!--more-->

## How it evolved

The project started with a commercial Sonic Xtone MIDI pedal paired with an external Raspberry Pi
for audio processing. When the pedal broke due to overvoltage, I decided to build my own.

1. **Modules & breadboard** — replaced the Xtone with a HifiBerry sound card module and an RP2040
   for MIDI processing and foot buttons
2. **First custom PCB (v2)** — through-hole board reusing existing modules (CM4 on a mini carrier board)
3. **SMD version (v3)** — cost-optimized surface-mount redesign, assembled on my own
   [pick-and-place machine](/projects/hardware/electronic-prototyping/)
4. **Display & USB (v4)** — current version with a separate display board (RGB LED rings + OLEDs),
   USB audio, and the HifiBerry replaced by a custom I²S sound card

## Architecture

Two independent processors — an RP2040 for MIDI control (instant startup, written in Rust) and a
CM4/CM5 running ELK Audio OS for real-time audio processing — connected over USB-MIDI.

## Skills involved

PCB design (KiCad), embedded firmware (Rust), real-time audio (ELK Audio OS),
3D-printed mechanical parts (OpenSCAD), and SMD assembly.

Licensed under CERN-OHL-P-2.0 — from free musicians for free musicians.

## Personal note

This project helped me find my way back from being a purely software engineer to working with
hardware again. It pulled me into 3D printing and [CNC milling](/projects/hardware/cnc/), and
ultimately led to my entire [electronic prototyping](/projects/hardware/electronic-prototyping/) setup.
