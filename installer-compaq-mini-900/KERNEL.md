# Kernel Configuration Notes - Compaq Mini 900

## Target Kernel
- **Version**: Latest stable that supports i686 architecture
- **Configuration**: Custom build optimized for Compaq Mini 900 hardware
- **Architecture**: x86 (32-bit), i686 CPU support

## Essential Drivers
- **CPU**: Intel Atom N270 support (i686 or proper Atom options)
- **Graphics**: Intel GMA 950 (i915 driver)
- **Storage**: SATA AHCI support
- **Networking**: Intel PRO/1000 Ethernet, appropriate WiFi driver based on model
- **USB**: EHCI/OHCI for USB 2.0 ports
- **Power**: ACPI support for power management

## Recommended Kernel Options
```
# Processor type and features
CONFIG_M386=y or CONFIG_M486=y (depending on exact CPU features)
CONFIG_HIGHMEM4G=y
CONFIG_X86_PAE=y (if using >1GB RAM)

# Device Drivers
CONFIG_FB_INTEL=y
CONFIG_DRM_I915=y
CONFIG_BACKLIGHT_LCD_SUPPORT=y
CONFIG_INTEL_MID_AUX_BD_CLAS=y

# File systems - ensure ext4, vfat (for /boot), and appropriate choices
CONFIG_EXT4_FS=y
CONFIG_VFAT_FS=y
CONFIG_FAT_FS=y
CONFIG_MSDOS_FS=y

# Networking
CONFIG_INET=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_8139CP=y or appropriate Ethernet driver
CONFIG_ATH9K_HTCS=m or appropriate WiFi driver
```

## Make.conf Settings for Compilation
For the Compaq Mini 900's limited RAM:
```
CHOST="i686-pc-linux-gnu"
CFLAGS="-O2 -march=i686 -mtune=generic -pipe"
CXXFLAGS="${CFLAGS}"
MAKEOPTS="-j2 -l2.0"  # Limit load to avoid memory issues
EMERGE_DEFAULT_OPTS="--jobs=1 --load-average=1.0"
FEATURES="buildpkg nospinner"
PORTAGE_ACTUAL_DISTDIR_CACHE="/var/cache/distfiles"
```

## Atom-Specific Optimizations
- Avoid aggressive optimizations that may not benefit the Atom architecture
- Use conservative CFLAGS
- Consider power management features

## Initramfs Considerations
- Create initramfs if needed for hardware support
- Keep it minimal due to limited storage

## Graphics Configuration
- The Intel GMA 950 requires specific kernel options
- X.org should use the intel driver
- May need EXA acceleration instead of UXA

## Power Management
- Enable CPU frequency scaling
- Enable laptop power management features
- Configure appropriate power profiles for netbook usage