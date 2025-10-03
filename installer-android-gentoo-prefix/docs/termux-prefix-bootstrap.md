Termux-Based Gentoo Prefix Bootstrap (Android aarch64)

Overview
- We cannot execute binaries from `/sdcard` (noexec). We place EPREFIX at `/data/local/tmp/gentoo` and use `/sdcard/gentoo` for large data.
- This guide uses Termux to provide a working compiler and tools.

Prerequisites
- Termux app installed on the device. This session installed: com.termux_1021.apk from F‑Droid.
- Ensure adb over Wi‑Fi is connected.

One-time setup (prepared by automation)
- Bootstrap script is created at `/sdcard/gentoo/termux-gentoo-prefix.sh`.
- Run it inside Termux:
  - Launch Termux on the phone.
  - In Termux, run: `bash /sdcard/gentoo/termux-gentoo-prefix.sh`

ADB install (already done here)
- Downloaded `https://f-droid.org/repo/com.termux_1021.apk` and installed via `adb install -r`.
- Launched activity: `cmd activity start -n com.termux/.app.TermuxActivity`.

What the script does
- Updates Termux packages and installs build essentials: `bash clang make binutils git curl tar gzip xz-utils sed findutils grep patch python coreutils`.
- Sets EPREFIX to `~/gentoo` inside Termux (SELinux-safe writable exec path).
- Downloads and runs Gentoo `bootstrap-prefix.sh` in noninteractive RAP mode for `aarch64-unknown-linux-gnu`.
- After bootstrap completes, you can enter the Prefix shell by sourcing the environment script as instructed by the bootstrap logs.

Data layout
- Executables and EPREFIX: `~/gentoo` (Termux home)
- Data (distfiles, binpkgs, logs): `/sdcard/gentoo` (after we configure Portage paths post-bootstrap)

Notes
- Run `termux-setup-storage` once to grant sdcard permissions.
- The bootstrap is lengthy (can be hours). Keep the device awake and Termux in foreground, or use `termux-wake-lock`.
