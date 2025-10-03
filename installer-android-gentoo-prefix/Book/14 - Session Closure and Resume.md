Captain,

Closing this session with a crisp snapshot and resume instructions.

Device + Context
- Active device: USB OnePlus6T; root available via `su` (context `u:r:magisk:s0`).
- `/sdcard` is noexec and disallows symlinks; executables live under `/data/local/tmp`.

State Summary
- Exec tools dir: `/data/local/tmp/run-bin` (contains static bash, binutils, make, symlinks to busybox applets, and a non-working proot).
- Alpine rootfs: `/data/local/tmp/gentoo-run-shell/alpine-rootfs` (extracted, chroot works).
- Network inside chroot OK; `apk update` succeeded earlier; current `apk` runs hit DB lock.
- Data dirs exist: `/sdcard/gentoo/{distfiles,logs}`.

What’s Blocked
- `apk add ...` in chroot fails with: `Unable to lock database` (likely lingering `/lib/apk/db/lock`).

Resume Checklist
1) Enter rooted Alpine chroot and clear lock, then install base tools:
   - `scripts/rooted-alpine-chroot.sh --cmd 'rm -f /lib/apk/db/lock; apk fix --no-progress apk-tools || true; echo nameserver 1.1.1.1 > /etc/resolv.conf; apk update; apk add --no-progress bash curl git tar xz coreutils findutils grep sed gawk patch make gcc g++ musl-dev python3'`
2) Start Gentoo Prefix bootstrap (EPREFIX on exec fs, distfiles on sdcard):
   - `scripts/rooted-alpine-chroot.sh --cmd 'export EPREFIX=/data/local/tmp/gentoo DISTDIR=/sdcard/gentoo/distfiles; mkdir -p "$EPREFIX" "$DISTDIR"; cd /root; curl -fLO https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh; bash ./bootstrap-prefix.sh 2>&1 | tee /bootstrap-prefix.log'`

Convenience
- Open shell inside chroot: `scripts/rooted-alpine-chroot.sh --shell`

Notes
- If `apk` lock persists, wait a minute and retry step 1. If needed, rebooting the device clears transient locks (non-persistent setup survives until reboot for `/data/local/tmp`, data on `/sdcard` persists).

Respectfully,
— I

