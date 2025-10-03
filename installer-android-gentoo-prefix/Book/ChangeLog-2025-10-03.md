2025-10-03

- Cleared Alpine `apk` DB lock inside rooted chroot and installed base packages (bash, curl, git, tar, xz, coreutils, findutils, grep, sed, gawk, patch, make, gcc, g++, musl-dev, python3).
- Verified Alpine rootfs at `/data/local/tmp/gentoo-run-shell/alpine-rootfs` on current device (USB-connected OnePlus6T); networking OK.
- Unblocked next phase: run Gentoo Prefix bootstrap with executables under `/data/local/tmp` and distfiles under `/sdcard/gentoo`.

