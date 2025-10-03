#!/usr/bin/env bash
set -euo pipefail

ADB_BIN="${ADB:-adb}"
ALPINE_ROOT="${ALPINE_ROOT:-/data/local/tmp/gentoo-run-shell/alpine-rootfs}"

usage() {
  echo "Usage: $0 [--shell] [--cmd \"<command>\"]" >&2
  exit 1
}

SHELL_MODE=0
RUN_CMD=""
while [ $# -gt 0 ]; do
  case "$1" in
    --shell) SHELL_MODE=1 ; shift ;;
    --cmd) shift; RUN_CMD="${1:-}"; shift || true ;;
    *) usage ;;
  esac
done

$ADB_BIN shell "su -c 'mkdir -p $ALPINE_ROOT/{proc,sys,dev,dev/pts} && \
  mount -o bind /proc $ALPINE_ROOT/proc || true; \
  mount -o bind /sys $ALPINE_ROOT/sys || true; \
  mount -o bind /dev $ALPINE_ROOT/dev || true; \
  mount -o bind /dev/pts $ALPINE_ROOT/dev/pts || true; \
  echo nameserver 1.1.1.1 > $ALPINE_ROOT/etc/resolv.conf'"

if [ "$SHELL_MODE" = 1 ]; then
  exec $ADB_BIN shell "su -c 'chroot $ALPINE_ROOT /bin/sh'"
fi

if [ -n "$RUN_CMD" ]; then
  exec $ADB_BIN shell "su -c 'chroot $ALPINE_ROOT /bin/sh -lc \"$RUN_CMD\"'"
fi

echo "Ready. Example: $0 --cmd 'apk update && apk add bash' or $0 --shell"

