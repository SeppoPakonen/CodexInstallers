Alpine Minirootfs (aarch64 3.15.0)

Goal
- Provide a minimal, exec‑capable userland to aid bootstrapping (optional when proceeding with native toolchain + Prefix).

Artifacts
- Archive in repo: `alpine-minirootfs-3.15.0-aarch64.tar.gz`

Extraction Targets
- Exec area (works): `/data/local/tmp/gentoo-run/alpine-rootfs`
- `/sdcard/gentoo` (not suitable): extraction hits link creation permission errors due to FUSE semantics; binaries would also be noexec.

Using the Helper
- `DEVICE_ADDR=192.168.1.107:37021 scripts/adb-setup.sh`
  - Pushes the tarball to device and extracts to `/data/local/tmp/gentoo-run/alpine-rootfs`.

Next Options
- With root + permissive sepolicy: chroot into Alpine (see Rooted-Chroot-Flow.md).
- Without root/chroot: use `proot.aarch64` to run Alpine rootfs (if required). Note: a prebuilt `proot` is included as `proot.aarch64`.

