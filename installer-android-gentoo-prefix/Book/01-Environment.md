01. My Environment And Constraints

I set up on a OnePlus 9 Pro running Android 15 (LineageOS 22.2) with root via Magisk. I connected over ADB Wi‑Fi (192.168.1.107; ports rotated during the session).

I confirmed that `/sdcard` is FUSE and noexec (and symlinks are denied), so I treated `/data/local/tmp` as the exec area. I created two roots:
- `/data/local/tmp/run-bin` for all executables and helper binaries I push.
- `/sdcard/gentoo` for distfiles, logs, and bulky data that doesn’t require exec.

On the device I relied only on `/system/bin/sh` and `curl`. Everything else I staged from the host. In the repo, I kept ready‑to‑push artifacts (Alpine minirootfs, static bash, and aarch64 proot) and used an NDK r26b on the host to build native tools.

