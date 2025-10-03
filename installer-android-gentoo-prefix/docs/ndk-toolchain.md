Android NDK r26b (aarch64) – quick usage

- Location: `toolchain-android/android-ndk-r26b`
- Compilers (wrappers): `.../toolchains/llvm/prebuilt/linux-x86_64/bin`
- Examples:
  - `aarch64-linux-android30-clang hello.c -o hello`
  - `clang --target=aarch64-linux-android30 --sysroot=$NDK/sysroot hello.c -o hello`

Device staging
- Executables should live under an exec-capable path, e.g. `/data/local/tmp/run-bin`.
- Bulk data can go under `/sdcard/gentoo`.

Notes
- r26b includes wrappers up to API 30; binaries run fine on Android 15.
- For API 35 wrappers, use a newer NDK (e.g., r27c) or pass `--target=aarch64-linux-android35` with a matching sysroot/CRTs.

Building a native Android toolchain (summary)
- Goal: produce `aarch64-linux-android` binutils and GCC (stage1) that run on-device without Termux.
- Host build uses NDK r26b Clang/LLD and NDK sysroot headers/libs.
- Configure tips:
  - binutils: `--host=aarch64-linux-android --target=aarch64-linux-android --disable-werror`
  - gcc stage1: `--host=aarch64-linux-android --target=aarch64-linux-android --without-headers --disable-nls --disable-lto --disable-plugin --enable-languages=c`
  - Set `CC`, `CXX`, `AR`, `AS`, `LD`, `RANLIB` to NDK toolchain binaries and export `--sysroot=$NDK/sysroot -D__ANDROID_API__=30` in `CFLAGS`/`LDFLAGS`.
  - Use bionic CRTs from NDK sysroot `.../usr/lib/aarch64-linux-android/30/` and device bionic libs if needed at runtime.
