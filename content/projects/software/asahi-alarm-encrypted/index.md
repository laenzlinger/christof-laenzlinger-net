---
Title: Arch Linux on Apple Silicon with Encrypted Disk
description: "Running Arch Linux ARM on a MacBook Pro M1 with full LUKS disk encryption, btrfs subvolumes, and the Asahi boot chain."
Tags: [linux, foss]
weight: 7
---

A fully encrypted Arch Linux ARM installation on a MacBook Pro 16" M1, using the Asahi boot chain
(m1n1 → U-Boot → GRUB) with LUKS encryption applied in-place after the initial install.
This post documents the complete process step by step.
<!-- more -->

## Hardware

- MacBook Pro 16" (2021), M1 Pro, 32GB RAM, 1TB SSD
- macOS retained on a minimal ~70GB partition (required for firmware updates)

## Why Asahi ALARM

The [Asahi Linux](https://asahilinux.org) project reverse-engineered Apple Silicon hardware support,
making it possible to run Linux on these machines. While Asahi offers a Fedora-based distribution,
the [Asahi ALARM](https://asahi-alarm.org) variant provides a minimal Arch Linux ARM base —
the same rolling-release, user-controlled approach I use on my ThinkPad.

## The Approach: Encrypt After Install

Most encryption guides format a LUKS partition first, then install into it. On Apple Silicon
this is impractical — the Asahi installer handles the complex partition layout and firmware
setup, and it expects to write directly to an unencrypted filesystem.

Instead, I use `cryptsetup reencrypt --encrypt` to encrypt the root partition **in-place** after
the initial install is complete and verified bootable. The advantages:

1. Start from a known-working boot — easier to debug before encryption
2. Preserve the btrfs filesystem and subvolumes created by the installer
3. Only requires a small filesystem shrink to fit the LUKS header

## Boot Chain

Apple Silicon uses a proprietary boot process. The Asahi project provides compatibility layers:

```text
m1n1 → U-Boot → GRUB → Linux kernel → initramfs unlocks LUKS → encrypted root
```

- **m1n1**: Apple Silicon bootloader shim, loaded from the APFS stub partition
- **U-Boot**: Provides standard UEFI firmware interface
- **GRUB**: Loads kernel and initramfs from the unencrypted EFI partition
- **initramfs**: The `encrypt` hook prompts for the LUKS passphrase and opens the volume

A critical design decision: GRUB does **not** unlock the encrypted partition. Only the initramfs
does. This avoids a known issue where U-Boot's keyboard handling on Apple Silicon drops
keystrokes — typing a long passphrase at the GRUB stage is unreliable, but the initramfs
prompt works perfectly.

## Phase 1: Asahi ALARM Installation

### Shrink macOS

Before running the installer, shrink the APFS container in Disk Utility to the minimum
(~70GB for macOS + recovery + firmware updates). This maximizes the space available for Linux.

### Run the Installer

From macOS Terminal:

```bash
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
```

Choose **"Asahi Alarm Minimal (BTRFS)"** and allocate all remaining space to Linux.
The installer creates two partitions:

- **EFI** (~500MB, FAT32) — contains m1n1, U-Boot, and the GRUB EFI binary
- **Root** (remaining space) — btrfs with `@` and `@home` subvolumes

After the installer finishes, reboot into the new ALARM environment and log in as `root`/`root`.

### Identify Partitions

```bash
lsblk
blkid
```

Note the device names (example values used throughout this guide):

```bash
EFI_PART=/dev/nvme0n1p4   # the FAT32 EFI partition (~500MB)
ROOT_PART=/dev/nvme0n1p5  # the btrfs root partition (large)
```

### Get Networking

```bash
nmcli device wifi connect <SSID> password <password>
ping -c1 archlinux.org
```

### Install Required Packages

```bash
pacman -Sy cryptsetup efibootmgr btrfs-progs inetutils git base-devel
```

## Phase 2: Move /boot to the EFI Partition

By default, the Asahi installer mounts the EFI partition at `/boot/efi` and keeps the kernel
and initramfs on the root partition under `/boot`. We need to move everything to the EFI
partition so that GRUB can load the kernel **without** accessing the encrypted root.

### Copy Boot Files to EFI

```bash
# Check current mount layout
mount | grep efi

# Unmount EFI from /boot/efi
umount /boot/efi

# Copy all boot files to the EFI partition
mount $EFI_PART /mnt
cp -a /boot/* /mnt/
umount /mnt

# Remount EFI as /boot
mount $EFI_PART /boot
```

### Update /etc/fstab

Edit `/etc/fstab` and change the EFI partition mount point from `/boot/efi` to `/boot`.
Remove any old `/boot` entry that referenced the root partition.

### Reinstall GRUB

GRUB must be reinstalled so its modules and config live on the EFI partition:

```bash
grub-install --target=arm64-efi --efi-directory=/boot
cp /boot/EFI/arch/grubaa64.efi /boot/EFI/BOOT/BOOTAA64.EFI
grub-mkconfig -o /boot/grub/grub.cfg
```

The `cp` ensures the EFI binary is at the fallback path, so U-Boot can always find it.

### Test Reboot

```bash
reboot
```

**This is the critical checkpoint.** Verify the system boots normally before proceeding.
If GRUB fails to load, use the rescue prompt:

```text
set prefix=(hd0,gpt4)/grub
insmod normal
normal
```

Do not proceed to encryption until boot works reliably.

## Phase 3: In-Place LUKS Encryption

With boot files safely on the EFI partition, the root partition can be encrypted.
The `cryptsetup reencrypt --encrypt` command encrypts a partition in-place without
destroying its contents. It needs a small amount of free space at the start of the
device for the LUKS header (32 MiB by default).

### Shrink the Btrfs Filesystem

Shrink by 256 MiB — generous margin because btrfs rounds resize operations to internal
chunk boundaries:

```bash
btrfs filesystem show /
btrfs filesystem resize 1:-256m /
btrfs filesystem show /
```

Verify the size actually decreased in the output. On a ~900GB disk, 256 MiB is 0.03% —
negligible.

### Add the encrypt Hook to Initramfs

The initramfs needs the `encrypt` hook to prompt for the LUKS passphrase at boot:

```bash
sed -i 's/block filesystems/block encrypt filesystems/' /etc/mkinitcpio.conf
grep ^HOOKS /etc/mkinitcpio.conf
```

The HOOKS line should now read:

```text
HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
```

Regenerate:

```bash
mkinitcpio -P
```

### Add `break` to GRUB Boot Entry

To drop into an initramfs shell (before root is mounted), temporarily add `break` to the
kernel command line:

```bash
sed -i '/^\s*linux \/vmlinuz/{/break/!s/$/ break/}' /boot/grub/grub.cfg
```

This makes the initramfs stop at a root shell instead of trying to mount the (not yet
encrypted) root partition.

### Reboot into the Initramfs Shell

```bash
reboot
```

You land in a root shell inside the initramfs. The root partition is **not mounted** —
this is exactly what we need for in-place encryption.

### Encrypt the Partition

```bash
mkdir -p /tmp
mount -t tmpfs tmpfs /tmp
cd /tmp
cryptsetup reencrypt --encrypt --reduce-device-size=32M --force-password /dev/nvme0n1p5
```

- Type `YES` when asked to confirm
- Enter and verify your LUKS passphrase
- Wait for completion (~20–25 minutes for ~900GB)

The `--reduce-device-size=32M` tells cryptsetup to reserve space for the LUKS header at the
front of the device. This is why we shrunk the filesystem by 256 MiB earlier — the filesystem
is now small enough that the LUKS header fits without overwriting data.

The default key derivation function is argon2id (strongest available). Since only the initramfs
needs to unlock this — not GRUB — there are no compatibility constraints.

## Phase 4: Configure Boot for Encrypted Root

Still in the initramfs shell after encryption completes.

### Open LUKS and Mount the System

```bash
cryptsetup open /dev/nvme0n1p5 cryptroot
mkdir /mnt
mount -o subvol=@ /dev/mapper/cryptroot /mnt
mount $EFI_PART /mnt/boot
```

### Chroot In

```bash
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /dev /mnt/dev
chroot /mnt
```

### Fix /etc/fstab

Update the root (`/`) and `/home` entries to use the decrypted mapper device:

```text
/dev/mapper/cryptroot  /       btrfs  rw,noatime,compress=zstd:1,space_cache=v2,subvol=@      0 0
/dev/mapper/cryptroot  /home   btrfs  rw,noatime,compress=zstd:1,space_cache=v2,subvol=@home  0 0
```

Remove `x-systemd.growfs` if present — the filesystem is now inside LUKS and won't be
auto-grown.

### Update GRUB Configuration

Get the UUID of the encrypted partition and configure GRUB to pass it to the initramfs:

```bash
blkid /dev/nvme0n1p5
```

Edit `/etc/default/grub` and set:

```text
GRUB_CMDLINE_LINUX="cryptdevice=UUID=<uuid-of-nvme0n1p5>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@"
```

Regenerate GRUB config (this also removes the `break` parameter):

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

### Reboot

```bash
exit
reboot -f
```

On reboot: GRUB loads the kernel from EFI → initramfs asks for the LUKS passphrase →
root mounts from `/dev/mapper/cryptroot`. You now have a fully encrypted system.

## Phase 5: Post-Install Configuration

After first successful encrypted boot, log in as `root`/`root`.

### Network

```bash
nmtui
```

### Additional Btrfs Subvolumes

Create subvolumes for snapshots and logs (keeps them separate from the main root):

```bash
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
umount /mnt
mkdir -p /.snapshots /var/log
```

Add to `/etc/fstab`:

```text
/dev/mapper/cryptroot  /.snapshots  btrfs  rw,noatime,compress=zstd:1,space_cache=v2,subvol=@snapshots  0 0
/dev/mapper/cryptroot  /var/log     btrfs  rw,noatime,compress=zstd:1,space_cache=v2,subvol=@var_log    0 0
```

```bash
mount /.snapshots
mount /var/log
```

### Create User

```bash
useradd -m -G wheel -s /bin/zsh laenzi
passwd laenzi
EDITOR=vim visudo   # uncomment: %wheel ALL=(ALL:ALL) ALL
```

### Set Hostname

```bash
hostnamectl set-hostname fender
```

### Add Backup LUKS Passphrase

Always add a second passphrase in case the primary is forgotten:

```bash
cryptsetup luksAddKey /dev/nvme0n1p5
```

### Apply Dotfiles

```bash
su - laenzi
git clone https://github.com/laenzlinger/dotfiles.git ~/.local/share/chezmoi
cd ~/.local/share/chezmoi
bash arch/setup-user.sh
```

## Apple Silicon Specifics

A few things that differ from a standard Arch install:

- **Kernel**: Must use `linux-asahi` — the generic ARM64 kernel lacks Apple hardware support
- **Speaker safety**: The `speakersafetyd` daemon must always run — without it, speakers can be
  physically destroyed by unfiltered audio signals
- **WiFi firmware**: Extracted from macOS by the `asahi-fwextract` package
- **GPU**: Mesa with Asahi's AGX driver provides OpenGL and Vulkan acceleration
- **Dual boot**: macOS is always accessible via the startup options menu (hold power button)
- **HiDPI console**: The console font is tiny on Retina displays — configure from the running
  system rather than trying to read the GRUB editor

## Troubleshooting

### GRUB Rescue

If GRUB cannot find its modules after the EFI rearrangement:

```text
set prefix=(hd0,gpt4)/grub
insmod normal
normal
```

### Btrfs Size Mismatch After Encryption

If you see "device total_bytes should be at most X but found Y", the btrfs filesystem was not
shrunk enough before encryption. Always shrink by 256 MiB — btrfs rounds internally and a
smaller margin may not be sufficient.

### Boot Chain Recovery

If boot fails completely, hold the power button to access macOS startup options. From macOS
you can mount the EFI partition (`diskutil mount disk0s4`) and fix GRUB configuration.

### Starting Over

If you need to reinstall, from macOS Terminal:

```bash
# Delete APFS stub container (check disk number first)
diskutil apfs deleteContainer disk3

# Delete EFI and Linux partitions
diskutil eraseVolume free free disk0s4
diskutil eraseVolume free free disk0s5

# Re-run installer
curl https://asahi-alarm.org/installer-bootstrap.sh | sh
```

## References

- [Asahi Linux](https://asahilinux.org) — Apple Silicon Linux project
- [Asahi ALARM installer](https://asahi-alarm.org) — Arch Linux ARM variant
- [Asahi Boot Process Guide](https://github.com/AsahiLinux/docs/blob/main/docs/alt/boot-process-guide.md) —
  detailed explanation of the m1n1 → U-Boot → GRUB chain
- [cryptsetup reencrypt](https://man.archlinux.org/man/cryptsetup-reencrypt.8) — in-place
  encryption documentation
- [Arch Wiki — dm-crypt](https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system)
