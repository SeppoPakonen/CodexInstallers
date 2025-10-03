Summary
- Active device switched to USB OnePlus6T as Wi‑Fi ADB refused 192.168.1.107:37021.
- `/data/local/tmp/gentoo-run` not writable (root:root); added fallback to `/data/local/tmp/gentoo-run-shell` and used it.
- Pushed static bash; verified it runs.
- Extracted Alpine 3.15.0 aarch64 into exec-capable fallback run area.
- Confirmed `/sdcard` noexec is enforced.
- `proot.aarch64` requires `libtalloc.so.2` (not static) → fails to start.

Decisions
- Keep executables in `/data/local/tmp/run-bin`; data under `/sdcard/gentoo`.
- Blocked on a static or self-contained aarch64 `proot` to run Alpine.

Next
- Obtain/build static `proot` aarch64 (Android/Bionic), restage, then smoke-test Alpine with `proot -0 -r`.
- If delayed, continue ADB-only toolchain build to enable Gentoo Prefix bootstrap without `proot`.

