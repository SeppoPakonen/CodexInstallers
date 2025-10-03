05. How I Bootstrapped Gentoo Prefix

I prepared the device PATH to include `/data/local/tmp/run-bin/bin` and `/data/local/tmp/run-bin`. I set `EPREFIX=/data/local/tmp/gprefix` so executables remain on an exec‑capable filesystem, and I set `DISTDIR=/sdcard/gentoo/distfiles` for bulk downloads.

I staged `bootstrap-prefix.sh` on `/sdcard/gentoo/` and ran it with the static bash I pushed earlier:
- `PATH=/data/local/tmp/run-bin/bin:/data/local/tmp/run-bin:$PATH \`
  `DISTDIR=/sdcard/gentoo/distfiles \`
  /data/local/tmp/run-bin/bash /sdcard/gentoo/bootstrap-prefix.sh /data/local/tmp/gprefix stage1`

I kept logs and artifacts under `/sdcard/gentoo` and left executables strictly in `/data/local/tmp` to respect the noexec constraint.

