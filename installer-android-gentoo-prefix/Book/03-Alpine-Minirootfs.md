03. What I Did With Alpine Minirootfs

I tried Alpine aarch64 3.15.0 first to have a minimal userland. I extracted it under `/data/local/tmp/gentoo-run/alpine-rootfs` (exec‑capable) and verified that `bin/sh` existed. Extracting under `/sdcard/gentoo` produced the expected link permission errors (FUSE) and would not be executable anyway, so I avoided that path.

I kept the Alpine archive in the repo and let `scripts/adb-setup.sh` push and extract it automatically when present. I left proot available in case I needed to run the rootfs without chroot.

