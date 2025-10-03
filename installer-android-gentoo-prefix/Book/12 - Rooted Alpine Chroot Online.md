Captain,

I pivoted from proot to the rooted-device flow and validated a working chroot into the Alpine 3.15.0 minirootfs.

Actions
- Mounted bind points and chrooted into `/data/local/tmp/gentoo-run-shell/alpine-rootfs` via `su` (SELinux context `magisk` allowed chroot).
- Confirmed environment inside Alpine with busybox (`uname`, `id`) and `/etc/os-release`.
- Added helper `scripts/rooted-alpine-chroot.sh` to set up mounts and enter a shell or run one-off commands.

Findings
- Chroot works without additional SELinux policy tweaks on this device (Enforcing, `u:r:magisk:s0`).
- `busybox` applets are available; `apk update` succeeds; large install runs may transiently lock the apk DB (retry resolves).

Next
- Use the chroot to install build basics (`bash curl git tar xz coreutils findutils grep sed gawk patch make gcc g++ musl-dev python3`).
- Proceed to run Gentoo Prefix bootstrap with `EPREFIX=/data/local/tmp/gentoo` and `DISTDIR=/sdcard/gentoo/distfiles` (bind mount paths as needed).

Respectfully,
— I

