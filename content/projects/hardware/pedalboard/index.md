---
Title: Pedalboard Hard and Software Platform
description: "Open source guitar effects pedalboard with custom PCB, Rust firmware on RP2040, real-time audio DSP on Raspberry Pi CM5, and MIDI control — designed in KiCad."
Tags: [electronics, embedded, raspberry-pi, foss]
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

The separation is deliberate: the control layer (foot switches, LEDs, MIDI routing) must respond
instantly regardless of what the audio engine is doing. The RP2040 boots in milliseconds and
handles all user interaction. The Compute Module handles DSP-heavy audio processing with
hard real-time guarantees via ELK Audio OS (Xenomai-patched Linux kernel).

## Technical Details

### Hardware (KiCad, 4-layer PCB)

- **Raspberry Pi CM5** — runs Debian + JACK + mod-host for real-time audio
- **RP2040** — Rust/RTIC firmware for MIDI control, foot switches, LED control
- **Custom I²S sound card** — PCM1863 ADC (106dB SNR) + PCM5242 DAC (112dB), replacing the HifiBerry
- **6 foot buttons** — momentary, toggle, radio group, long-press, multi-action sequences
- **12-LED WS2812B RGB rings** per button — spatial patterns + animations synced to BPM
- **2 rotary encoders** — preset scrolling, parameter control, tap tempo
- **2 expression pedal inputs** — continuous real-time control (wah, volume, plugin parameters)
- **2 SSD1327 OLED displays** — button labels, encoder overlays, BPM display
- **DIN + USB MIDI** — control any MIDI gear, bidirectional
- **30mm flat CNC aluminum case** — sits under your foot, not on top of your pedalboard

### Firmware (Rust, RTIC)

The RP2040 firmware is written entirely in Rust using the RTIC real-time framework:

- USB-MIDI device class with MIDI-CI Property Exchange for configuration
- Foot switch debouncing and long-press detection via input polling task
- WS2812B LED control via SPI (98 LEDs total)
- SSD1327 OLED rendering via I²C
- Preset persistence in flash (32 presets, survive power cycles)
- OpenDeck SysEx compatibility for web-based button configuration
- Configuration as code — YAML setlists uploaded via CLI over WebSocket→MIDI

### Audio Processing (JACK, mod-host, AIDA-X)

- **1.33ms buffer latency** (64 frames @ 48kHz) — ~2.7ms total roundtrip
- **AIDA-X neural amp modeling** — RTNeural inference at 3.4% CPU per model instance
- **LV2 plugin ecosystem** — hundreds of open source effects (reverb, delay, chorus, EQ)
- **MOD UI** — drag-and-drop plugin routing in the browser for tone design
- **mod-host** — headless LV2 host controlled via TCP from the bridge service
- **pedalboard-bridge** (Go) — WebSocket↔MIDI bridge + audio patch switching

### Software Components

| Component | Language | Description |
|-----------|----------|-------------|
| [pedalboard-midi](https://github.com/pedalboard/pedalboard-midi) | Rust | RP2040 firmware — buttons, LEDs, encoders, MIDI, display |
| [pedalboard-cli](https://github.com/pedalboard/pedalboard-cli) | Rust | YAML setlists → device upload via Property Exchange |
| [pedalboard-bridge](https://github.com/pedalboard/pedalboard-bridge) | Go | WebSocket↔MIDI bridge + audio patch switching |
| [pedalboard-protocol](https://github.com/pedalboard/pedalboard-protocol) | Rust | Shared config types + MIDI-CI PE framing |
| [pedalboard-hw](https://github.com/pedalboard/pedalboard-hw) | KiCad | Main board schematics + PCB |
| [pedalboard-soundcard](https://github.com/pedalboard/pedalboard-soundcard) | KiCad | Custom I²S audio codec |
| [pedalboard-display](https://github.com/pedalboard/pedalboard-display) | KiCad | RGB LED rings + OLED display board |

## Skills involved

PCB design (KiCad), embedded firmware (Rust), real-time audio (ELK Audio OS),
3D-printed mechanical parts (OpenSCAD), and SMD assembly.

Licensed under CERN-OHL-P-2.0 — from free musicians for free musicians.

## Why open source

Commercial guitar pedalboard solutions are closed, expensive, and inflexible. As a working
musician, I want to own my tools — modify them, fix them, adapt them to my workflow. Open
hardware and open source firmware make this possible. The CERN-OHL-P license ensures anyone
can build, modify, and share improvements.

## Personal note

This project helped me find my way back from being a purely software engineer to working with
hardware again. It pulled me into 3D printing and [CNC milling](/projects/hardware/cnc/), and
ultimately led to my entire [electronic prototyping](/projects/hardware/electronic-prototyping/) setup.
