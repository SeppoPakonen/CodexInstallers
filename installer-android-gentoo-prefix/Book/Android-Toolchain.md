Android Toolchain (binutils + GCC stage1)

Goal
- Produce runnable Android aarch64 toolchain components for the device without Termux, using NDK r26b on the host.

Script
- `scripts/build-android-toolchain.sh`
  - Uses NDK r26b: `toolchain-android/android-ndk-r26b`
  - Builds: binutils 2.42 and GCC 13.2.0 stage1 (C only)
  - Output: `builds/out-run-bin/` (installed with `/` prefix into DESTDIR)
  - Key flags:
    - binutils: `--host=--target=aarch64-linux-android`, disables gdb/gdbserver/sim/gprofng
    - gcc: `--host=--target=aarch64-linux-android --without-headers --disable-nls --disable-lto --disable-plugin --disable-multilib --enable-languages=c`
  - Environment:
    - Build CFLAGS kept generic; target flags use NDK sysroot and `-D__ANDROID_API__=30` via `*_FOR_TARGET` variables.

Usage
- Build binutils only (fast path while iterating):
  - `SKIP_GCC=1 scripts/build-android-toolchain.sh`
- Full build (binutils + GCC stage1):
  - `scripts/build-android-toolchain.sh`

Push to Device
- `DEVICE_ADDR=192.168.1.107:37021 SRC_DIR=builds/out-run-bin scripts/push-run-bin.sh`
- On device, binaries live under `/data/local/tmp/run-bin/bin` (ld, as, ar, nm, strip, objdump, etc.).

Validation
- `adb shell '/data/local/tmp/run-bin/bin/ld -v'` → should show `GNU ld (GNU Binutils) 2.42`.

Notes
- The GCC build downloads and builds GMP/MPFR/MPC via `contrib/download_prerequisites`.
- If network is flaky, the script retries and verifies tarballs; it auto‑refetches on corruption.

