#!/usr/bin/env bash
set -euo pipefail

DEVICE_ADDR="${DEVICE_ADDR:-192.168.1.107:37021}"
ADB_BIN="${ADB:-adb}"
SRC_DIR="${SRC_DIR:-$PWD/builds/out-run-bin}"
DEST_DIR="/data/local/tmp/run-bin"

if [ ! -d "$SRC_DIR" ]; then
  echo "[push-run-bin] Source dir not found: $SRC_DIR" >&2
  exit 1
fi

"$ADB_BIN" connect "$DEVICE_ADDR" || true
"$ADB_BIN" shell "mkdir -p $DEST_DIR"
"$ADB_BIN" push "$SRC_DIR"/. "$DEST_DIR"/ >/dev/null
"$ADB_BIN" shell "chmod -R 0755 $DEST_DIR && ls -l $DEST_DIR"

echo "[push-run-bin] Pushed tools to $DEST_DIR on $DEVICE_ADDR"

