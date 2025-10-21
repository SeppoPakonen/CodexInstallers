STATUS — Gentoo on iMac A1228

Last updated: after LILO + rEFIt setup; preparing to restart and redo install with 32-bit (i686) userland.

Host details
- Model: Apple iMac A1228 (2007 era; 64‑bit CPU with 32‑bit EFI typical)
- Live env: Gentoo Minimal CD (SSH in as root)
- Target disk: /dev/sda

Partition layout (GPT)
- sda1 ESP 200MiB FAT32 (flag: esp)
- sda2 BIOS boot 1MiB (flag: bios_grub)
- sda3 Linux swap 2GiB
- sda4 Linux ext4 root (rest of disk)

UUIDs (current)
- ROOT (sda4) UUID=4161aa1b-c024-4991-b3be-fd0e7b71adbd
- SWAP (sda3) UUID=5f81307b-84e7-4dc7-9b0a-324e4dd340b7
- ESP  (sda1) UUID=E319-BD78

Mounts used during install
- /mnt/gentoo → sda4 (ext4)
- /mnt/gentoo/boot/efi → sda1 (vfat)
- /proc, /sys, /dev, /run bind-mounted into /mnt/gentoo

Base system (to be replaced)
- Current root contains the amd64/x32 systemd stage; this install will be abandoned in favor of pure 32-bit i686 with OpenRC.
- Portage tree already synced via webrsync and can be reused after untarring the new stage.
- Locale/timezone currently set to fi_FI.UTF-8 and UTC—reuse if desired during reinstall.
- make.conf currently tuned for x32; plan to regenerate for i686 profile (see NOTES below).

Swap
- Partition: 2G (sda3) available (currently inactive while target unmounted)
- Swapfile: `/swap.4g` present inside root filesystem; decide whether to recreate after reinstall.

fstab (written)
- ROOT → /
- SWAP partition and /swap.4g entries present
- ESP mounted at /boot/efi (vfat, umask=0077)

Bootloaders
- rEFIt 0.14 (EFI IA32): copied to ESP with `BOOTIA32.EFI` pointing to refit.efi; config enables `legacyfirst` and defaults to Linux entry.
- rEFInd (EFI IA32): remains on ESP under `EFI/refind`; optional if we keep both menus.
- LILO 24.2 (BIOS): installed to MBR with `/etc/lilo.conf` targeting `kernel-6.12.41-gentoo` (x32 build). Will need re-run after installing new i686 kernel.
- Syslinux files remain but considered fallback only—safe to remove once i686 install validated.
- GRUB: still blocked under x32; revisit post i686 install if desired.

Kernel
- Current /boot holds `kernel-6.12.41-gentoo` + matching initramfs from the x32 build; these will be replaced by the i686 build artifacts.

Next steps (i686 reinstall plan)
1) Reboot back into the minimal install environment (or BionicPup) and re-mount `/mnt/gentoo` as needed.
2) Remove or archive the current root (`rm -rf /mnt/gentoo/*`) after double-checking mounts.
3) Download the latest i686 OpenRC stage3 (e.g. `https://distfiles.gentoo.org/releases/x86/autobuilds/current-stage3-i686-openrc/stage3-i686-openrc-<date>.tar.xz`) and extract to `/mnt/gentoo`.
4) adopt the `default/linux/x86/23.0/i686/openrc` profile; adjust `/etc/portage/make.conf` for i686 (see NOTES.md for new COMMON_FLAGS and ACCEPT_KEYWORDS suggestions).
5) Reinstall kernel (recommended: `sys-kernel/gentoo-kernel-bin` i686 variant, or `gentoo-sources` + `genkernel`), then rerun `lilo -v` inside chroot.
6) Update `/etc/fstab` with new UUIDs if they change (current UUIDs above still valid if partitions untouched).
7) Optionally keep rEFInd or remove; ensure rEFIt still default loader if desired.
8) Finish system setup (passwd, NetworkManager, sudo, user accounts) and reboot.
