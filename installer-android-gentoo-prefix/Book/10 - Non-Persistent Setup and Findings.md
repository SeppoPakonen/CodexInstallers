10. Non‑Persistent Setup and Findings

I started by aligning with Captain’s constraints: all work must happen over ADB, no Termux on device, binaries cannot reliably execute from `/sdcard`, and we should keep data rooted at `/sdcard/gentoo` while staging executables somewhere exec-capable.

I created two working roots: `/sdcard/gentoo` for persistent data and `/data/local/tmp/gentoo-run` for executables. I fetched the provided static bash and installed it at `/data/local/tmp/gentoo-run/bin/bash`, then verified it runs fine. I tested `/sdcard` execution: as expected, it’s mounted noexec; direct execution and symlink creation failed. I confirmed scripts can run when invoked as `sh /sdcard/...`, but Android’s toybox `sh` drops positional args for scripts on `/sdcard`, so wrappers there can’t relay CLI args reliably. A stub at `/sdcard/gentoo/bin/bash` that `exec`s the staged bash works for interactive use but still can’t forward arguments robustly.

I moved on to Alpine 3.15.0 (aarch64). I extracted the minirootfs successfully under an exec-capable path (`/data/local/tmp/gentoo-run/alpine-rootfs`). Extraction directly into `/sdcard/gentoo` caused many `Permission denied` errors (hardlinks/symlinks vs FUSE semantics), so I kept the rootfs under the exec area and treated `/sdcard/gentoo` as bulk storage (e.g., `distfiles`, logs). I began exploring `proot` to run the Alpine rootfs without kernel `chroot`. Several common links only provided x86_64 binaries; those don’t run on arm64. I identified we need a known-good Android aarch64 `proot` (or build one with the Android NDK) to proceed with Alpine-in-proot.

In parallel, I prepared an ADB‑only toolchain path: I installed the Android NDK r26b on the host at `toolchain-android/android-ndk-r26b`, tested an aarch64 hello world, and validated push/run via ADB. I started building binutils (host/target `aarch64-linux-android`) with NDK clang/lld. That build previously timed out mid-way and will be resumed. I also staged `bootstrap-prefix.sh` to `/sdcard/gentoo/bootstrap-prefix.sh` for a Gentoo Prefix route; it’s blocked for now by the absence of a working compiler on-device (per our no‑Termux constraint).

I documented a rooted-device fallback with SELinux policy tweaks for `chroot` via `magiskpolicy --live`, in case Captain prefers a true chroot flow later. That can be made persistent via a tiny Magisk module, but we’ll defer per his preference. Until then, `proot` remains the cleanest non‑persistent path for running Alpine or Prefix.

My recommendation stands: keep executables under an exec-capable path like `/data/local/tmp/gentoo-run` (or a final EPREFIX there) and store bulky data under `/sdcard/gentoo`. If Captain insists on an EPREFIX rooted at `/sdcard/gentoo`, we’ll maintain a mirrored exec tree with wrappers; execution must still originate from exec-capable storage due to the noexec/FUSE limitations.

Next, I intend to either 1) obtain or build a working Android aarch64 `proot` and run Alpine from `/data/local/tmp/gentoo-run/alpine-rootfs`, or 2) continue the ADB-only toolchain build to enable a straight Gentoo Prefix bootstrap with `EPREFIX` in the exec area and `DISTDIR` on `/sdcard/gentoo`.

