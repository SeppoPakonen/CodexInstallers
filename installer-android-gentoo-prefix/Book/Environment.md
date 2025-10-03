Environment & Constraints

Device
- Model: OnePlus 9 Pro (aarch64)
- OS: Android 15 / LineageOS 22.2 (SDK 34)
- Root: Available via Magisk (note: some builds deny chroot via SELinux; see Rooted-Chroot-Flow.md)

Connectivity
- ADB over Wi‑Fi. Recent address: 192.168.1.107 with ports 40425 → 37021.

Filesystem
- Executable paths: `/data/local/tmp` (exec)
- Data paths: `/sdcard` (FUSE; noexec, symlinks usually denied)
- Strategy: executables under `/data/local/tmp/run-bin`; bulk data under `/sdcard/gentoo`.

On‑Device Tools
- `/system/bin/sh` (toybox) and `curl` available. No bash/make/cc by default.

Repo Artifacts
- Alpine minirootfs aarch64 3.15.0: `alpine-minirootfs-3.15.0-aarch64.tar.gz`
- Static bash (aarch64): `bash-static-aarch64`
- proot (aarch64): `proot.aarch64`
- Host NDK: `toolchain-android/android-ndk-r26b`

Key Paths
- Exec tools on device: `/data/local/tmp/run-bin`
- Staging area: `/data/local/tmp/gentoo-run`
- Gentoo data: `/sdcard/gentoo/{distfiles,logs}`
- Optional Alpine rootfs: `/data/local/tmp/gentoo-run/alpine-rootfs`

