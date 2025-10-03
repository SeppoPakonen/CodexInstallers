Summary
- Tools: `/data/local/tmp/run-bin` (bash OK; proot not usable).
- Alpine: `/data/local/tmp/gentoo-run-shell/alpine-rootfs` (rooted chroot OK).
- Data: `/sdcard/gentoo/{distfiles,logs}`.
- Pending: clear Alpine apk DB lock; install base packages; run Prefix bootstrap with `EPREFIX=/data/local/tmp/gentoo`.

Resume Commands
- Clear lock + install: see `scripts/rooted-alpine-chroot.sh` with `--cmd` in `Book/14 - Session Closure and Resume.md`.
- Enter shell: `scripts/rooted-alpine-chroot.sh --shell`.

