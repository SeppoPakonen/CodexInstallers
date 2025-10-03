Context
- Device: OnePlus9Pro (Android SDK 34), ABI arm64-v8a.
- Connectivity (recent):
  - Previous: adb over Wi‑Fi at 192.168.1.102:39929.
  - Current device: 192.168.1.107, initial port 40425, updated to 37021.
- Writable dirs: /data/local/tmp (exec), /sdcard (FUSE, typically noexec).
 - Tools on device: /system/bin/sh and curl; no bash/make/cc.

Common Practices
- Inherits repo-wide guidance from the root `AGENTS.md` for remote session hygiene (tmux/transcripts), destructive-op confirmations, filesystem identifiers, and documentation/logging conventions. Android-specific constraints and procedures below override as needed.

User Goals
- Use install path rooted at `/sdcard/gentoo`.
- Keep progress and decisions in markdown files so session can be closed safely.
- Try running with Alpine minirootfs 3.15.0 (aarch64) first.
- Provided a static bash URL: https://github.com/robxu9/bash-static/releases/download/5.2.015-1.2.3-2/bash-linux-aarch64
- Later: Prefer a rooted-device flow to avoid Termux/proot friction.

Constraints & Strategy
- `/sdcard` is typically a noexec filesystem; binaries placed there usually cannot be executed.
- We will stage executable tooling under `/data/local/tmp/gentoo-run` and store bulk data under `/sdcard/gentoo`.
- If we must run binaries from the `/sdcard` tree later, we’ll use wrappers that execute counterparts from `/data/local/tmp/gentoo-run`.

Non‑Persistent vs Persistent Setup
- Non‑persistent: operate entirely from `/data/local/tmp` (exec) and `/sdcard/gentoo` (data). Survives until reboot; no Magisk module required.
- Persistent (deferred): package SELinux policy tweaks and mounts into a Magisk module to enable chroot at boot; bind mount data paths as needed. Not implemented yet per user preference.

Plan
1) Create `/sdcard/gentoo` (data) and `/data/local/tmp/gentoo-run` (exec tools).
2) Fetch and test provided static `bash` into `/data/local/tmp/gentoo-run/bin/bash`.
3) Verify exec behavior on `/sdcard` (expect noexec) and document results.
4) Locate Alpine minirootfs tarball locally or download if absent; extract under `/sdcard/gentoo/alpine-rootfs`.
5) Evaluate execution options (proot/static chroot helpers) given noexec; if needed, mirror rootfs to exec area for bootstrapping, while keeping data on `/sdcard`.
6) If Alpine path is viable, proceed; otherwise bootstrap Gentoo Prefix with bash using exec staging and final data at `/sdcard/gentoo`.

Open Questions
- Exact local path of `alpine-minirootfs-3.15.0-aarch64.tar.gz` if already downloaded on host; otherwise we can fetch.

Progress Log
- Created `/sdcard/gentoo` and `/data/local/tmp/gentoo-run/bin`.
- Installed static bash to `/data/local/tmp/gentoo-run/bin/bash` and verified it runs.
- Verified `/sdcard` is noexec (running a script there fails with `Permission denied`).
- Alpine minirootfs extracted to exec-capable `/data/local/tmp/gentoo-run/alpine-rootfs` successfully; extraction into `/sdcard/gentoo` produced many `Permission denied` link errors due to FUSE semantics.
- Attempted to fetch static `proot` for aarch64; common URLs tried, only found x86_64 build (not runnable on device). Need a known-good aarch64 static `proot` if we are to run Alpine rootfs.
\- Installed Android NDK r26b on host at `toolchain-android/android-ndk-r26b`; validated aarch64 hello world and basic device push/run via ADB.
\- Began native Android toolchain build (ADB-only path): started binutils build targeting/hosting `aarch64-linux-android` using NDK r26b clang/lld; long build previously timed out midway — to be resumed.
\- Staged bootstrap-prefix.sh to `/sdcard/gentoo/bootstrap-prefix.sh`; invocation blocked pending a native compiler in PATH on device (no Termux allowed).

Exec Bridging Experiments
- Symlinks on `/sdcard` are not allowed (creation fails with `Permission denied`).
- Executing scripts directly from `/sdcard` fails (`noexec`).
- Invoking scripts via `sh /sdcard/...` works to run them, but toybox `sh` does not forward positional arguments when the script is on `/sdcard` (observed `ARGS:0`).
- A stub at `/sdcard/gentoo/bin/bash` that does `exec /data/local/tmp/gentoo-run/bin/bash` launches interactive bash correctly, but cannot relay CLI arguments.


Recommendation
- Keep executables under `/data/local/tmp/gentoo` (EPREFIX) and store bulky data (distfiles, binpkgs, tree snapshots) under `/sdcard/gentoo`.
- If strict requirement is EPREFIX at `/sdcard/gentoo`, this will not run directly due to noexec; we can maintain a mirror and wrappers, but execution must originate from an exec-capable path.

Next Steps (Proposed)
- For Alpine-in-proot path: obtain a prebuilt `proot` for aarch64 Android (preferred), or cross-compile `proot` using Android NDK (host-build) and stage a static-ish binary.
- If going straight to Gentoo Prefix, we need a working compiler on-device; typical route is via Termux (clang/make), then run `bootstrap-prefix.sh` targeting an exec-capable EPREFIX and `DISTDIR` on `/sdcard/gentoo`.

ADB‑Only Toolchain Plan (active)
- Build native `aarch64-linux-android` binutils and GCC stage1 using NDK r26b (Clang/LLD) on host, targeting Bionic:
  - host=`aarch64-linux-android`, target=`aarch64-linux-android` (Canadian-cross style build on host, deploy to device).
  - Use NDK sysroot and CRTs from `toolchain-android/android-ndk-r26b/toolchains/llvm/prebuilt/linux-x86_64/sysroot`.
  - Stage resulting `{ld,as,ar,nm,gcc}` to `/data/local/tmp/run-bin` and verify on device.

Rooted Device Path (prepared)
- A dedicated guide is available: docs/rooted-android-prefix.md:1.
- Summary: extract Alpine to `/data/local/alpine`, mount `/proc` `/sys` `/dev`, chroot, install build tools, and run Prefix bootstrap with `EPREFIX=/data/local/gentoo`. Optionally bind-mount `/data/local/gentoo` to `/sdcard/gentoo`.

Session Closure Notes
- Termux-based bootstrap script staged at `/sdcard/gentoo/termux-gentoo-prefix.sh` (EPREFIX `~/gentoo`) and documented in docs/termux-prefix-bootstrap.md:1.
- proot sources cloned locally at `proot-src/` for future work if ever needed.
- Verified device characteristics and constraints; sdcard is noexec and disallows symlinks.

Non‑Negotiable Constraint
- All work must be performed via ADB connection only. Do not use Termux (no installation, no runtime tools). Document and implement flows without Termux. If a compiler or tooling is required on-device, prefer pushing prebuilt aarch64 Android binaries via ADB or cross‑compiling on host and staging under `/data/local/tmp`.

Quick Pointers (current session)
- Static bash on device: `/data/local/tmp/run-bin/bash`
- Make on device: `/data/local/tmp/run-bin/make` (from Termux .deb, bionic-linked)
- Distfiles/logs: `/sdcard/gentoo/{distfiles,logs}`
- NDK r26b (host): `toolchain-android/android-ndk-r26b`
- Bootstrap script: `/sdcard/gentoo/bootstrap-prefix.sh`

LineageOS + SELinux (Chroot Notes)
- On some LineageOS builds, `su` is in the `magisk` SELinux domain and `chroot` is denied even with root.
- Non‑persistent workaround (applies until reboot):
  - `adb shell su -c "magiskpolicy --live \"allow magisk magisk:capability2 sys_chroot\""`
  - Optionally also allow for `shell`: `adb shell su -c "magiskpolicy --live \"allow shell shell:capability2 sys_chroot\""`
  - Re‑try: `adb shell su -c 'chroot /data/local/tmp/gentoo /bin/sh -c "echo chroot-ok"'`
- Persistent approach (to consider later):
  - Package the above `magiskpolicy` rules in a tiny Magisk module (run in `post-fs-data`) so they apply on boot.
  - Or integrate equivalent `allow` rules into the ROM/device sepolicy if building LineageOS yourself.
- Alternative (no policy changes): use `proot` to run the Gentoo tree without kernel `chroot`.


Book Logging Protocol
- Follows the repo-wide pattern described in root `AGENTS.md` (Documentation & Logs). Android-specific nuance: write human chapters in first person ("I") and, where appropriate, address the user with titles such as Spearhead, Captain, Curator, Director, Chief, or Ringleader (context dependent). Favor small, frequent updates and keep logs in sync with actual progress.
