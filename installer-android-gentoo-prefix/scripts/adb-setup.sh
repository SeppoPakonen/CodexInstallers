#!/usr/bin/env bash
set -euo pipefail

DEVICE_ADDR="${DEVICE_ADDR:-192.168.1.107:37021}"
ADB_BIN="${ADB:-adb}"

# Paths on device
RUN_BASE="/data/local/tmp"
RUN_BIN="$RUN_BASE/run-bin"
RUN_AREA="$RUN_BASE/gentoo-run"
# Fallback if RUN_AREA is not writable (e.g., owned by root from prior runs)
RUN_AREA_FALLBACK="$RUN_BASE/gentoo-run-shell"
SDCARD_GENTOO="/sdcard/gentoo"

# Artifacts in repo
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BASH_BIN="$REPO_ROOT/bash-static-aarch64"
PROOT_BIN="$REPO_ROOT/proot.aarch64"
ALPINE_TARBALL="$REPO_ROOT/alpine-minirootfs-3.15.0-aarch64.tar.gz"

log() { printf "[adb-setup] %s\n" "$*"; }

die() { echo "[adb-setup][ERROR] $*" >&2; exit 1; }

require() { command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"; }

require "$ADB_BIN"
[ -f "$BASH_BIN" ] || die "Missing $BASH_BIN"
[ -f "$PROOT_BIN" ] || log "proot not found at $PROOT_BIN (optional)."
[ -f "$ALPINE_TARBALL" ] || log "Alpine tarball not found at $ALPINE_TARBALL (optional)."

log "Connecting to $DEVICE_ADDR"
"$ADB_BIN" connect "$DEVICE_ADDR" || true

log "Checking devices"
"$ADB_BIN" devices -l | sed '1d'

log "Ensuring directories on device"
"$ADB_BIN" shell "mkdir -p $RUN_BIN $RUN_AREA $SDCARD_GENTOO/distfiles $SDCARD_GENTOO/logs || true"
if ! "$ADB_BIN" shell "test -w $RUN_AREA" >/dev/null 2>&1; then
  log "RUN_AREA not writable: $RUN_AREA. Falling back to $RUN_AREA_FALLBACK"
  "$ADB_BIN" shell "mkdir -p $RUN_AREA_FALLBACK"
  RUN_AREA="$RUN_AREA_FALLBACK"
fi

log "Pushing static bash to $RUN_BIN/bash"
"$ADB_BIN" push "$BASH_BIN" "$RUN_BIN/bash" >/dev/null
"$ADB_BIN" shell "chmod 0755 $RUN_BIN/bash && $RUN_BIN/bash --version | head -n1"

if [ -f "$PROOT_BIN" ]; then
  log "Pushing proot to $RUN_BIN/proot"
  "$ADB_BIN" push "$PROOT_BIN" "$RUN_BIN/proot" >/dev/null
  "$ADB_BIN" shell "chmod 0755 $RUN_BIN/proot && $RUN_BIN/proot --version 2>/dev/null | head -n1 || true"
fi

if [ -f "$ALPINE_TARBALL" ]; then
  log "Pushing Alpine minirootfs to $RUN_BASE"
  remote_tar="$RUN_BASE/$(basename "$ALPINE_TARBALL")"
  "$ADB_BIN" push "$ALPINE_TARBALL" "$remote_tar" >/dev/null
  log "Extracting Alpine into $RUN_AREA/alpine-rootfs (exec-capable)"
  "$ADB_BIN" shell "mkdir -p $RUN_AREA/alpine-rootfs && toybox tar -xzf $remote_tar -C $RUN_AREA/alpine-rootfs"
  log "Verifying Alpine sh exists"
  "$ADB_BIN" shell "ls -l $RUN_AREA/alpine-rootfs/bin/sh"
fi

log "Testing /sdcard noexec behavior (expected: Permission denied for direct exec)"
"$ADB_BIN" shell "echo -e '#!/system/bin/sh\necho hello' > $SDCARD_GENTOO/noexec-test.sh && chmod 0755 $SDCARD_GENTOO/noexec-test.sh && $SDCARD_GENTOO/noexec-test.sh || echo '[ok] noexec enforced'"

log "Done. Useful paths:"
echo "  - bash:    $RUN_BIN/bash"
echo "  - proot:   $RUN_BIN/proot (if pushed)"
echo "  - alpine:  $RUN_AREA/alpine-rootfs (if extracted)"
echo "  - sdcard:  $SDCARD_GENTOO"
