ADB‑Only Workflow

Overview
- No Termux runtime. All tooling is pushed via ADB or cross‑compiled on the host using the Android NDK.
- Executables live under `/data/local/tmp/run-bin`; data under `/sdcard/gentoo`.

Prep Script
- `scripts/adb-setup.sh` prepares directories, pushes `bash-static-aarch64`, optional `proot.aarch64`, and can extract Alpine rootfs.
- Example: `DEVICE_ADDR=192.168.1.107:37021 scripts/adb-setup.sh`

Push Built Tools
- `scripts/push-run-bin.sh` syncs `builds/out-run-bin` to `/data/local/tmp/run-bin`.
- Example: `DEVICE_ADDR=192.168.1.107:37021 SRC_DIR=builds/out-run-bin scripts/push-run-bin.sh`

Verify On Device
- `adb shell '/data/local/tmp/run-bin/bash --version'`
- `adb shell '/data/local/tmp/run-bin/bin/ld -v'`

Noexec Behavior (Documented)
- Direct exec from `/sdcard` fails (expected). `sh /sdcard/...` works, but toybox `sh` may not pass positional args when script is on `/sdcard`.

