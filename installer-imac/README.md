Gentoo Install — iMac A1228 (2007)

This repository tracks a remote Gentoo installation performed over SSH from a Gentoo Minimal CD/BionicPup live session to an iMac A1228. Target configuration uses GPT with both EFI (32‑bit) and BIOS boot paths, a single ext4 root, a 2G swap partition, and an additional 4G swapfile.

Use these docs to resume or repeat the process reliably.

- See STATUS.md for the current on-disk state and what has been completed.
- See KERNEL.md for kernel build options and how to proceed with gentoo‑sources.
- See BOOT.md for details on rEFInd and Syslinux setup and how to finalize boot configs after installing a kernel.

IMPORTANT: The installation was interrupted and we are now reinstalling with i686 OpenRC stage3 to ensure compatibility with the 32-bit EFI environment of this iMac.

When ready to continue the install, resume from the steps in STATUS.md → Next Steps.
