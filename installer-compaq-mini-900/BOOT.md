# Boot Configuration - Compaq Mini 900

## Bootloader Options
For the Compaq Mini 900 with legacy BIOS:

### Option 1: GRUB Legacy (Recommended for old BIOS)
- More compatible with older BIOS implementations
- Simpler configuration for basic boot scenarios

### Option 2: SYSLINUX
- Lightweight alternative
- Good for simple boot scenarios
- Excellent for BIOS-based systems

## Partition Considerations
- **BIOS Boot**: Legacy BIOS (not UEFI)
- **Boot Partition**: /dev/sda1 (FAT32 recommended for compatibility)
- **Size**: 512MB minimum
- **Mount Point**: /boot

## GRUB Legacy Installation Steps
1. Install GRUB to MBR:
   ```bash
   grub-install --no-floppy /dev/sda
   ```
2. Generate configuration:
   ```bash
   grub-mkconfig -o /boot/grub/grub.conf
   ```

## SYSLINUX Installation Steps
1. Install syslinux:
   ```bash
   emerge syslinux
   ```
2. Install to boot sector:
   ```bash
   extlinux --install /boot
   ```
3. Update MBR:
   ```bash
   dd bs=440 count=1 conv=notrunc if=/usr/share/syslinux/mbr.bin of=/dev/sda
   ```

## Kernel Parameters for Compaq Mini 900
- **Graphics**: `i915.fastboot=1` for Intel GMA 950
- **Power**: `intel_idle.max_cstate=1` for older Atom power management
- **Storage**: No special parameters typically needed for SATA
- **Memory**: No special parameters, but consider limiting framebuffers

## Example /boot/grub/grub.conf
```
default 0
timeout 5

title Gentoo Linux Compaq Mini 900
root (hd0,0)
kernel /vmlinuz root=/dev/sda3 ro i915.fastboot=1 intel_idle.max_cstate=1
initrd /initramfs-genkernel-x86.img
```

## Boot Partition Filesystem
- **Format**: FAT32 (most compatible with older BIOS)
- **Mount Options**: defaults in /etc/fstab (UUID preferred)

## Udev Considerations
- Use persistent network naming (biosdevname disabled)
- Ensure consistent device naming for boot

## Troubleshooting Boot Issues
- If boot fails, try with `nomodeset` kernel parameter
- For graphics issues, try adding `i915.i915_enable_fbc=1` for framebuffer compression
- For power issues, try `acpi=off` or `noapic` (last resort)

## Recovery Options
- Prepare a bootable USB stick with a live system
- Keep kernel sources for rebuilding if needed
- Document partition layout and UUIDs in NOTES.md