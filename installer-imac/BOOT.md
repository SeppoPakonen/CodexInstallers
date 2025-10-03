BOOT — rEFInd (EFI), Syslinux (BIOS), and LILO fallback

Overview
- EFI boot: rEFInd IA32 remains on the ESP so the Mac’s boot picker (Option key) finds it via `\EFI\BOOT\BOOTIA32.EFI`.
- BIOS boot (primary while GRUB is deferred): install and maintain LILO in the GPT/BIOS path.
- Legacy Syslinux notes are left for reference but LILO should replace it once configured and tested.

What’s already done
- ESP (sda1) mounted at `/boot/efi`.
- rEFInd files installed:
  - `\EFI\BOOT\BOOTIA32.EFI`
  - `\EFI\refind\refind.efi`
  - `\EFI\refind\drivers_ia32` and tools (optional)
  - `\EFI\refind\refind.conf` includes `scan_all_linux_kernels true` and a placeholder GRUB entry
- Syslinux previously installed for BIOS (can be left as an emergency fallback until LILO verified):
  - GPT MBR written from `gptmbr.bin` to /dev/sda and `parted -s /dev/sda set 4 legacy_boot on`
  - `extlinux --install /boot/extlinux`
  - `/boot/extlinux/extlinux.conf` present with placeholder kernel/initramfs paths
- GRUB not installed (build blocked under x32 due to ms_abi); LILO is the BIOS loader we will configure now.

Prepare to chroot
1. Mount the target root and ESP from the live environment:
```
mount /dev/sda4 /mnt/gentoo
mount -o umask=0077 /dev/sda1 /mnt/gentoo/boot/efi
```
2. Bind the live system resources and enter the chroot:
```
mount -t proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys && mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev && mount --make-rslave /mnt/gentoo/dev
mount --rbind /run /mnt/gentoo/run || true
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
```

Install and configure LILO
- Install the package (the live minimal CD has no network mirrors configured for us, so this assumes Portage sync already done inside the target):
```
emerge --ask sys-boot/lilo
```
- Create `/etc/lilo.conf` tailored to the installed kernel. Example template (adjust filenames to match the actual kernel/initramfs in `/boot`):
```
lba32
compact
boot = /dev/sda
timeout = 50
prompt
default = gentoo

image = /boot/vmlinuz-gentoo
  label = gentoo
  read-only
  append = "root=UUID=4161aa1b-c024-4991-b3be-fd0e7b71adbd ro"
  initrd = /boot/initramfs-gentoo.img

image = /boot/vmlinuz-gentoo.old
  label = gentoo-old
  read-only
  append = "root=UUID=4161aa1b-c024-4991-b3be-fd0e7b71adbd ro"
  optional
```
  - Replace the UUID with the current root filesystem UUID from `blkid` if it changes.
  - `lba32` is required for disks beyond 8 GiB.
  - Keep a second stanza handy for rollback once you have more than one kernel.
- Ensure `/etc/lilo.conf` paths match files on the root filesystem (remember `/boot` inside the chroot is the target’s `/boot`).
- Write the loader to the disk MBR (GPT is supported by recent LILO builds):
```
lilo -v
```
  - Rerun `lilo` after every kernel or initramfs update.
  - If LILO complains about GPT, double-check the package USE flag `gpt` is enabled (it is on by default since LILO 24.2). Add `sys-boot/lilo gpt` to `/etc/portage/package.use` if needed and reinstall.

Testing and cleanup
- Exit the chroot and unmount as usual (`exit`, then `umount -R /mnt/gentoo`, `swapoff` as appropriate) before rebooting.
- Once LILO proves reliable you can remove or archive the Syslinux installation (`/boot/extlinux`) to avoid confusion.
- Keep rEFInd on the ESP—its EFI path offers a second boot option if BIOS boot fails.

Reference material
- Gentoo LILO guide (requires network): https://wiki.gentoo.org/wiki/LILO
- Because outbound network access is restricted in this environment we mirror the key steps above; consult the wiki when you have direct access for advanced options (e.g., enabling framebuffer splash, serial console).
