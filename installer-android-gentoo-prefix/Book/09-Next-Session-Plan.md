09. Next Session Plan (ADB‑Only)

Where I left off
- Alpine aarch64 3.15 extracted under `/data/local/tmp/proot-alpine-rootfs` and chroot works.
- Alpine networking OK for root (HTTP/HTTPS/DNS). As non-root `builder`, wget/curl DNS for distfiles is denied (Android restriction intersecting with chroot namespacing).
- Build tools installed inside chroot: `bash curl wget tar xz coreutils findutils grep sed gawk patch make gcc g++ musl-dev git python3 ca-certificates su-exec`.
- Gentoo Prefix bootstrap script downloaded to `/root/bootstrap-prefix.sh` in chroot.
- EPREFIX intended: `/data/local/tmp/gprefix` (exec filesystem). DISTDIR: `/sdcard/gentoo/distfiles`.

Two viable paths (choose one next):
- Fast path: run bootstrap as root (patch local `/root/bootstrap-prefix.sh` to skip root refusal) inside chroot.
- Non-root path: prefetch stage distfiles as root to `/sdcard/gentoo/distfiles`, then run bootstrap as `builder` so downloads come from `DISTDIR` only.

Commands to resume (rooted chroot)
- Enter chroot: `adb shell su -c 'chroot /data/local/tmp/proot-alpine-rootfs /bin/sh'`
- Bootstrap (root-bypass option): edit the root check in `/root/bootstrap-prefix.sh`, then:
  - `export EPREFIX=/data/local/tmp/gprefix DISTDIR=/sdcard/gentoo/distfiles`
  - `bash /root/bootstrap-prefix.sh 2>&1 | tee /bootstrap-prefix.log`

Commands to resume (non-root with prefetch)
- In chroot as root:
  - `mkdir -p /sdcard/gentoo/distfiles`
  - Prefetch a minimal set when prompted by logs; or let me script mirrored fetches.
- As builder:
  - `su-exec builder:builder /bin/sh -lc 'export EPREFIX=/data/local/tmp/gprefix DISTDIR=/sdcard/gentoo/distfiles; cd /home/builder; cp /root/bootstrap-prefix.sh .; bash ./bootstrap-prefix.sh 2>&1 | tee /home/builder/bootstrap-prefix.log'`

What I will do on “continue”
- Confirm which path you prefer (root-bypass vs prefetch-as-root).
- Apply it and drive bootstrap through stage1.
- Document deltas in this Book and update docs/CONTINUE.md.

