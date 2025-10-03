Gentoo Prefix Bootstrap (ADB‑Only)

Principles
- Executables live under `/data/local/tmp` (exec). Bulk data under `/sdcard/gentoo`.
- No Termux runtime; all tools are pushed or cross‑compiled.

Prerequisites
- On device:
  - Static bash at `/data/local/tmp/run-bin/bash` (from `scripts/adb-setup.sh`).
  - Binutils and (eventually) GCC in `/data/local/tmp/run-bin/bin` (from toolchain build).
- On host:
  - NDK r26b installed at `toolchain-android/android-ndk-r26b` (for initial builds).

Environment
- `EPREFIX=/data/local/tmp/gprefix`
- `DISTDIR=/sdcard/gentoo/distfiles`
- `PATH=/data/local/tmp/run-bin/bin:/data/local/tmp/run-bin:$PATH`

Bootstrap Command
- `adb shell 'PATH=/data/local/tmp/run-bin/bin:/data/local/tmp/run-bin:$PATH DISTDIR=/sdcard/gentoo/distfiles /data/local/tmp/run-bin/bash /sdcard/gentoo/bootstrap-prefix.sh /data/local/tmp/gprefix stage1'`

Notes
- `/sdcard` is noexec; do not place executables there. Keep only distfiles/logs/snapshots.
- If you must store scripts on `/sdcard`, invoke with absolute interpreter (e.g., `/data/local/tmp/run-bin/bash /sdcard/...`).

