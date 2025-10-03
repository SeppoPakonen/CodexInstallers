Scope
- Device: OnePlus 9 Pro (SDK 34, arm64-v8a)
- ADB-only, no Termux. Data under `/sdcard/gentoo`, exec under `/data/local/tmp/gentoo-run`.

Actions
- Created `/sdcard/gentoo` (data) and `/data/local/tmp/gentoo-run` (exec tools).
- Installed static bash → `/data/local/tmp/gentoo-run/bin/bash` and verified.
- Verified `/sdcard` noexec; symlinks disallowed; `sh /sdcard/...` drops args.
- Extracted Alpine 3.15.0 aarch64 under exec path; `/sdcard` extraction hit FUSE link perms.
- Searched for Android aarch64 `proot`; only found x86_64 in common mirrors.
- Installed NDK r26b on host; validated aarch64 hello-world via ADB.
- Began binutils build targeting `aarch64-linux-android` (to resume).
- Staged `bootstrap-prefix.sh` to `/sdcard/gentoo/` (blocked: no compiler on device).

Findings
- `/sdcard` is unsuitable for executing binaries and for hardlink/symlink-heavy untars.
- Wrappers on `/sdcard` can’t reliably pass CLI args due to toybox `sh` behavior.

Recommendations
- Keep executables (EPREFIX or staging) under exec storage; use `/sdcard/gentoo` for distfiles, logs.
- Prefer `proot` for Alpine/Prefix without kernel `chroot`. Otherwise, pursue rooted `chroot` with SELinux tweak.

Next Steps
- Acquire/build Android aarch64 `proot` and run Alpine rootfs.
- Or continue ADB-only toolchain (binutils → gcc stage1) to enable Prefix bootstrap.

User Reference
- Static bash: `/data/local/tmp/run-bin/bash`
- Make: `/data/local/tmp/run-bin/make`
- Distfiles/logs: `/sdcard/gentoo/{distfiles,logs}`
- NDK: `toolchain-android/android-ndk-r26b`
- Bootstrap script: `/sdcard/gentoo/bootstrap-prefix.sh`

Tone
- Write human chapters in first person; refer to user as Spearhead/Captain/Curator/Director/Chief/Ringleader (contextual).

