Rooted Android: Gentoo Prefix via Alpine chroot

Summary
- Goal: Install Gentoo Prefix on a rooted Android device with minimal friction and full exec/symlink support.
- Approach: Use an Alpine Linux minirootfs in a chroot, then bootstrap Gentoo Prefix inside it.

Pre-reqs
- Root access available via `su` (Magisk/SuperSU).
- ADB over Wi‑Fi or USB working.
- Alpine aarch64 minirootfs tarball available (example used here: `alpine-minirootfs-3.15.0-aarch64.tar.gz`).

Paths
- Alpine rootfs: `/data/local/alpine`
- Gentoo Prefix (EPREFIX): `/data/local/gentoo`
- Optional shared storage (data): `/sdcard/gentoo`

Step 1: Push Alpine and extract (root)
```
adb push alpine-minirootfs-3.15.0-aarch64.tar.gz /data/local/tmp/
adb shell su -c 'mkdir -p /data/local/alpine'
adb shell su -c 'toybox tar -xzf /data/local/tmp/alpine-minirootfs-3.15.0-aarch64.tar.gz -C /data/local/alpine'
```

Step 2: Mount core filesystems in chroot
```
adb shell su -c 'mount -t proc proc /data/local/alpine/proc'
adb shell su -c 'mount -o bind /sys /data/local/alpine/sys'
adb shell su -c 'mount -o bind /dev /data/local/alpine/dev'
adb shell su -c 'mkdir -p /data/local/alpine/dev/pts && mount -o bind /dev/pts /data/local/alpine/dev/pts'
adb shell su -c 'echo nameserver 1.1.1.1 > /data/local/alpine/etc/resolv.conf'
```

Step 3: Enter chroot and install build tools
```
adb shell su -c 'chroot /data/local/alpine /bin/sh -lc "apk update && apk add bash curl tar xz coreutils findutils grep sed gawk patch make gcc g++ musl-dev git python3"'
```

Step 4: Bootstrap Gentoo Prefix inside chroot
```
adb shell su -c 'chroot /data/local/alpine /bin/sh -lc "export EPREFIX=/data/local/gentoo; export CHOST=aarch64-unknown-linux-gnu PREFIX_DISABLE_RAP=no TODO=noninteractive; cd /root; curl -fLO https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh; bash ./bootstrap-prefix.sh 2>&1 | tee /bootstrap-prefix.log"'
```

Notes
- The bootstrap is lengthy; keep the device awake.
- After bootstrap, enter Prefix by sourcing the environment script the bootstrap creates (e.g., `/data/local/gentoo/startprefix` if provided, or `/data/local/gentoo/usr/bin/prefix-env`).

Optional: Present EPREFIX at /sdcard/gentoo (bind mount)
```
adb shell su -c 'mkdir -p /data/local/gentoo /sdcard/gentoo'
adb shell su -c 'mount --bind /data/local/gentoo /sdcard/gentoo'
adb shell su -c 'mount -o remount,bind,exec /sdcard/gentoo'
```
- This makes `/sdcard/gentoo` appear as the Prefix location for convenience while execution remains from `/data/local/gentoo`.
- Symlinks on emulated sdcard still won’t work; bind mounts solve most needs.

Portage data on shared storage (after bootstrap)
- Inside the Prefix environment, configure Portage to use `/sdcard/gentoo` for heavy data:
```
mkdir -p /sdcard/gentoo/distfiles /sdcard/gentoo/packages
cat >> /data/local/gentoo/etc/portage/make.conf <<'EOF'
DISTDIR="/sdcard/gentoo/distfiles"
PKGDIR="/sdcard/gentoo/packages"
EOF
```

Troubleshooting
- chroot fails with “No such file or directory”: ensure `/data/local/alpine/bin/sh` exists and mounts for `/proc`, `/sys`, `/dev`, `/dev/pts` are present.
- DNS issues: ensure `/data/local/alpine/etc/resolv.conf` has a valid nameserver.
- Permission denied on `/sdcard`: use bind mounts for run paths; keep execution paths under `/data/local`.

Un-mount and cleanup (when needed)
```
adb shell su -c 'umount /data/local/alpine/dev/pts || true'
adb shell su -c 'umount /data/local/alpine/dev || true'
adb shell su -c 'umount /data/local/alpine/sys || true'
adb shell su -c 'umount /data/local/alpine/proc || true'
```

