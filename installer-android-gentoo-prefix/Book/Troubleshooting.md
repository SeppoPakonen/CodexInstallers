Troubleshooting

Connectivity
- ADB over Wi‑Fi unreachable: re‑run `adb connect 192.168.1.107:37021` or use USB; scripts tolerate reconnects.

Noexec on /sdcard
- Symptom: `Permission denied` when executing binaries from `/sdcard`.
- Action: keep executables in `/data/local/tmp`; invoke scripts on `/sdcard` via absolute interpreter.

Alpine Extraction Errors on /sdcard
- Symptom: many `Permission denied` for links.
- Action: extract to exec area `/data/local/tmp/gentoo-run/alpine-rootfs` instead.

binutils build errors in gprofng
- Symptom: pthread_cancelstate or similar missing on Android.
- Action: configure with `--disable-gprofng --disable-gdb --disable-gdbserver --disable-sim` (script already does this).

GCC build errors: missing `asm/types.h`
- Symptom: errors from NDK headers including `linux/types.h` → `asm/types.h` not found.
- Cause: leaking target sysroot into build‑host CFLAGS.
- Action: keep build‑host CFLAGS generic; set `CFLAGS_FOR_TARGET`/`LDFLAGS_FOR_TARGET` with sysroot. Implemented in `scripts/build-android-toolchain.sh`.

`ld` not found at `/data/local/tmp/run-bin/ld`
- Action: use `/data/local/tmp/run-bin/bin/ld`. Binutils install places tools in `bin/` under DESTDIR.

