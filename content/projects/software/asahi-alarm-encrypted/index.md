---
Title: Arch Linux on Apple Silicon with Encrypted Disk
description: "Running Arch Linux ARM on a MacBook Pro M1 with full LUKS disk encryption, btrfs subvolumes, and the Asahi boot chain."
Tags: [linux, foss]
weight: 7
---

A fully encrypted Arch Linux ARM installation on a MacBook Pro 16" M1, using the Asahi boot chain
(m1n1 → U-Boot → GRUB) with LUKS encryption applied in-place after the initial install.
<!-- more -->

## Hardware

MacBook Pro 16" (2021) with the M1 Pro processor, 32GB RAM, and a 1TB SSD. macOS is retained on a
minimal ~70GB partition for firmware updates — Apple Silicon requires macOS for low-level firmware
maintenance.

## Why Asahi ALARM

The [Asahi Linux](https://asahilinux.org) project reverse-engineered Apple Silicon hardware support,
making it possible to run Linux on these machines. While Asahi offers a Fedora-based distribution,
the [Asahi ALARM](https://asahi-alarm.org) variant provides a minimal Arch Linux ARM base —
the same rolling-release, user-controlled approach I use on my ThinkPad.

## Boot Chain

The boot process on Apple Silicon is more complex than on standard UEFI PCs:

m1n1 → U-Boot → GRUB → kernel → initramfs unlocks LUKS → encrypted root

The key design decision: GRUB does **not** unlock the encrypted partition. Only the initramfs does.
This avoids a known issue where U-Boot's keyboard handling on Apple Silicon drops keystrokes —
typing a long passphrase at the GRUB stage is unreliable, but the initramfs prompt works perfectly.

The kernel, initramfs, and GRUB all live on the unencrypted EFI partition (`/boot`).

## Encryption Strategy

Rather than reinstalling from scratch onto an encrypted partition, I used `cryptsetup reencrypt
--encrypt` to encrypt the root partition **in-place** after the initial Asahi ALARM install.
This approach:

1. Starts from a known-working boot (easier to debug)
2. Preserves the btrfs filesystem and subvolumes created by the installer
3. Requires only a small filesystem shrink (256 MiB) to make room for the LUKS header

The in-place encryption takes about 20–25 minutes on the ~900GB partition. After encryption,
the initramfs `encrypt` hook handles the LUKS unlock at every boot.

## Filesystem Layout

The root partition uses btrfs with subvolumes, matching my ThinkPad setup:

| Subvolume    | Mount Point    |
| ------------ | -------------- |
| `@`          | `/`            |
| `@home`      | `/home`        |
| `@snapshots` | `/.snapshots`  |
| `@var_log`   | `/var/log`     |

All subvolumes are on the same LUKS-encrypted block device (`/dev/mapper/cryptroot`), with
zstd compression and space_cache=v2.

## Apple Silicon Specifics

A few things that differ from a standard Arch install:

- **Kernel**: Must use `linux-asahi` — the generic ARM64 kernel lacks Apple hardware support
- **Speaker safety**: The `speakersafetyd` daemon must always be running — without it, the
  speakers can be physically destroyed by unfiltered audio signals
- **WiFi firmware**: Extracted from macOS by the `asahi-fwextract` package
- **GPU**: Mesa with Asahi's AGX driver provides OpenGL and Vulkan acceleration
- **Dual boot**: macOS is always accessible via the startup options menu (hold power button)

## Configuration Management

After the base install, all further configuration is handled by
[chezmoi](https://www.chezmoi.io) from my dotfiles repository. The same dotfiles manage both
this machine ("fender") and my ThinkPad ("gibson"), with machine-specific differences handled
through chezmoi templates.

## Lessons Learned

**Test boot before encrypting.** Moving `/boot` to the EFI partition and getting GRUB working
correctly is the hardest part. Verify the system boots cleanly before starting the irreversible
in-place encryption.

**Shrink generously.** Btrfs rounds resize operations to internal chunk boundaries. Shrinking by
only 32 MiB (the LUKS header size) may not be enough — I shrink by 256 MiB to be safe. On a
~900GB disk, this is negligible.

**GRUB rescue recovery.** If GRUB cannot find its modules after the EFI rearrangement:
`set prefix=(hd0,gpt4)/grub`, `insmod normal`, `normal`. This gets you back to a working boot
menu.
