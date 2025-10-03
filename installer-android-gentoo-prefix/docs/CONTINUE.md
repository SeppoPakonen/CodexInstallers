Resume Checklist

- Verify ADB to device `192.168.1.107:37021` is connected and root is available.
- Export NDK r26b paths on host: `NDK=$PWD/toolchain-android/android-ndk-r26b`.
- Build binutils for `aarch64-linux-android` using NDK Clang/LLD with NDK sysroot.
- Build GCC stage1 (C only) for `aarch64-linux-android` with `--without-headers --disable-nls --disable-lto --disable-plugin`.
- Stage `{as,ld,ar,nm,ranlib,gcc}` to `/data/local/tmp/run-bin` via `adb push`.
- Test on device: `adb shell /data/local/tmp/run-bin/gcc --version`.
- Run Gentoo Prefix bootstrap:
  - `adb shell \
    'PATH=/data/local/tmp/run-bin:$PATH \
     DISTDIR=/sdcard/gentoo/distfiles \
     /data/local/tmp/run-bin/bash /sdcard/gentoo/bootstrap-prefix.sh /data/local/tmp/gprefix stage1'`

Helper Script
- Use `scripts/adb-setup.sh` to push tools, create directories, and (optionally) extract Alpine rootfs under exec path:
  - `DEVICE_ADDR=192.168.1.107:37021 scripts/adb-setup.sh`
  - Artifacts used: `bash-static-aarch64`, `proot.aarch64` (optional), `alpine-minirootfs-3.15.0-aarch64.tar.gz` (optional).
  - Creates: `/data/local/tmp/run-bin`, `/data/local/tmp/gentoo-run`, `/sdcard/gentoo/{distfiles,logs}`.

Notes
- Keep executables under `/data/local/tmp`; keep caches under `/sdcard/gentoo`.
- If chroot is required later, consult `AGENTS.md` SELinux policy notes.

Alternative (ADB-only, no chroot): proot Alpine bootstrap
- Requires: `/data/local/tmp/run-bin/proot` and Alpine rootfs at `/data/local/tmp/gentoo-run/alpine-rootfs`.
- Run: `DEVICE_ADDR=192.168.1.107:37021 EPREFIX=/data/local/tmp/gprefix DISTDIR=/sdcard/gentoo/distfiles scripts/proot-alpine-bootstrap.sh`
- This runs the Gentoo Prefix bootstrap inside Alpine via proot and keeps EPREFIX on an exec-capable path.

Session Close Snapshot (2025-10-02)
- Alpine chroot prepared at `/data/local/tmp/proot-alpine-rootfs`; networking OK as root.
- Tools installed; bootstrap script at `/data/local/tmp/proot-alpine-rootfs/root/bootstrap-prefix.sh`.
- Next decision: run bootstrap as root (patch local root-check) or prefetch as root and run as builder.
- Target: `EPREFIX=/data/local/tmp/gprefix`, `DISTDIR=/sdcard/gentoo/distfiles`.

Quick Resume Commands
- Enter chroot as root: `adb shell su -c 'chroot /data/local/tmp/proot-alpine-rootfs /bin/sh'`
- Start bootstrap (root-bypass):
  - `export EPREFIX=/data/local/tmp/gprefix DISTDIR=/sdcard/gentoo/distfiles`
  - `bash /root/bootstrap-prefix.sh 2>&1 | tee /bootstrap-prefix.log`
- Or start as builder with prefetch:
  - `su-exec builder:builder /bin/sh -lc 'export EPREFIX=/data/local/tmp/gprefix DISTDIR=/sdcard/gentoo/distfiles; cd /home/builder; cp /root/bootstrap-prefix.sh .; bash ./bootstrap-prefix.sh 2>&1 | tee /home/builder/bootstrap-prefix.log'`

Book Follow-up Task (next)
- Add a short “Design Rationale” paragraph to each Book chapter (01–06). I’ll handle this first on next continue.
