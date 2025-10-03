Rooted Chroot Flow (Optional)

Summary
- With root (Magisk) and permissive SELinux rules, you can chroot into Alpine and run the Gentoo Prefix bootstrap with full POSIX semantics (exec, symlinks).

Key Steps (see also docs/rooted-android-prefix.md)
- Push Alpine: `adb push alpine-minirootfs-3.15.0-aarch64.tar.gz /data/local/tmp/`
- Extract as root: `adb shell su -c 'mkdir -p /data/local/alpine && toybox tar -xzf /data/local/tmp/alpine-minirootfs-3.15.0-aarch64.tar.gz -C /data/local/alpine'`
- Mount: proc, sys, dev, dev/pts; set resolv.conf.
- Chroot: `adb shell su -c 'chroot /data/local/alpine /bin/sh'`

SELinux Notes
- Some LineageOS builds deny `sys_chroot`. Temporary, non‑persistent policy update (until reboot):
  - `adb shell su -c "magiskpolicy --live \"allow magisk magisk:capability2 sys_chroot\""`
  - Optional for `shell` domain as well.
- Persistent method: package the rules in a Magisk module’s `post-fs-data`.

Prefix Inside Chroot
- Set `EPREFIX=/data/local/gentoo`, run the Gentoo Prefix bootstrap script with required tools installed via Alpine’s `apk`.

