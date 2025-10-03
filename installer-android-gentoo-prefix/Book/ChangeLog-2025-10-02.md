Change Log – 2025‑10‑02

Context
- Device: OnePlus 9 Pro, Android 15 (SDK 34), root via Magisk.
- ADB over Wi‑Fi at 192.168.1.107 (ports 40425 → 37021).
- `/sdcard` noexec, symlinks denied; exec area under `/data/local/tmp`.

What Was Implemented
- ADB helper: `scripts/adb-setup.sh` (creates dirs, pushes static bash/proot, extracts Alpine rootfs, tests `/sdcard` noexec).
- Push helper: `scripts/push-run-bin.sh` (sync `builds/out-run-bin` → `/data/local/tmp/run-bin`).
- Toolchain build: `scripts/build-android-toolchain.sh` (binutils 2.42 + GCC 13.2.0 stage1 via NDK r26b; resilient downloads; disables gdb/gdbserver/sim/gprofng; uses `*_FOR_TARGET` env to avoid sysroot leakage).
- Docs updated in this Book and `docs/` for quick continues.

Results
- Built binutils and staged to device. Verified: `adb shell '/data/local/tmp/run-bin/bin/ld -v'` → GNU ld 2.42.
- GCC stage1 build in progress using the script; will output into `builds/out-run-bin` and then be pushed to `/data/local/tmp/run-bin`.

Known Constraints & Decisions
- Keep executables under `/data/local/tmp/run-bin`; use `/sdcard/gentoo` for distfiles/logs only.
- Alpine extracted only to exec area due to `/sdcard` FUSE limitations.
- Optional rooted chroot flow documented with SELinux notes.

Next Steps
- Let GCC stage1 complete, push to device, then run Gentoo Prefix bootstrap:
  - `adb shell 'PATH=/data/local/tmp/run-bin/bin:/data/local/tmp/run-bin:$PATH DISTDIR=/sdcard/gentoo/distfiles /data/local/tmp/run-bin/bash /sdcard/gentoo/bootstrap-prefix.sh /data/local/tmp/gprefix stage1'`

Log Updates (Book)
- Added human chapter: `Book/10 - Non-Persistent Setup and Findings.md` (first-person; refers to user as Captain).
- Added compact summary: `Book/Non-Persistent-Setup-and-Findings.md` (agent-focused bullets).
- Documented process in `AGENTS.md` under “Book Logging Protocol” to keep Book entries current.

- Added fallback run area `/data/local/tmp/gentoo-run-shell` when root-owned path blocks writes.
- Staged Alpine 3.15.0 under fallback; verified `/sdcard` noexec.
- Noted `proot.aarch64` needs `libtalloc.so.2` (non-static); action: replace with static aarch64 Android proot or build via NDK.

- Added rooted chroot helper: scripts/rooted-alpine-chroot.sh.
- Validated Alpine chroot; documented resume in Book/14 - Session Closure and Resume.md and Book/Session-Resume.md.
- Pending task: clear apk DB lock inside chroot, install base packages, start Gentoo Prefix bootstrap (EPREFIX=/data/local/tmp/gentoo, DISTDIR=/sdcard/gentoo/distfiles).
