#!/usr/bin/env bash
set -euo pipefail

DEVICE_ADDR="${DEVICE_ADDR:-192.168.1.107:37021}"
ADB_BIN="${ADB:-adb}"

RUN_BASE="/data/local/tmp"
RUN_BIN="$RUN_BASE/run-bin"
# Allow override; default to a shell-writable path
ALPINE_ROOT="${ALPINE_ROOT:-$RUN_BASE/proot-alpine-rootfs}"
EPREFIX="${EPREFIX:-/data/local/tmp/gprefix}"
DISTDIR="${DISTDIR:-/sdcard/gentoo/distfiles}"

log() { printf "[proot-alpine] %s\n" "$*"; }
die() { echo "[proot-alpine][ERROR] $*" >&2; exit 1; }

"$ADB_BIN" connect "$DEVICE_ADDR" || true

# Sanity checks
"$ADB_BIN" shell "test -x $RUN_BIN/proot" || die "Missing $RUN_BIN/proot on device"
"$ADB_BIN" shell "test -d $ALPINE_ROOT && ls -l $ALPINE_ROOT/bin/sh >/dev/null" || die "Missing Alpine rootfs at $ALPINE_ROOT"

# Ensure DNS inside Alpine
log "Writing resolv.conf in Alpine"
"$ADB_BIN" shell "echo 'nameserver 1.1.1.1' > $ALPINE_ROOT/etc/resolv.conf"

# Update and install base build tools in Alpine via proot
log "Updating apk index and installing base tools"
"$ADB_BIN" shell "$RUN_BIN/proot -0 -R $ALPINE_ROOT -b /proc -b /sys -b /dev -b /dev/pts -w /root /bin/sh -lc 'apk update && apk add bash curl tar xz coreutils findutils grep sed gawk patch make gcc g++ musl-dev git python3'"

# Fetch Gentoo Prefix bootstrap inside proot Alpine and run stage1
log "Fetching and running Gentoo Prefix bootstrap inside proot (EPREFIX=$EPREFIX)"
"$ADB_BIN" shell "$RUN_BIN/proot -0 -R $ALPINE_ROOT -b /proc -b /sys -b /dev -b /dev/pts -b $DISTDIR:$DISTDIR -b $RUN_BASE:$RUN_BASE -w /root /bin/sh -lc 'export EPREFIX=$EPREFIX DISTDIR=$DISTDIR; curl -fLO https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh && bash ./bootstrap-prefix.sh 2>&1 | tee /bootstrap-prefix.log'"

log "Done. To re-enter proot shell:"
echo "  adb shell '$RUN_BIN/proot -0 -R $ALPINE_ROOT -b /proc -b /sys -b /dev -b /dev/pts -w /root /bin/sh'"
