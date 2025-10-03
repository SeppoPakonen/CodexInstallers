Summary
- Tools: `/data/local/tmp/run-bin` (bash OK; proot not usable).
- Alpine: `/data/local/tmp/gentoo-run-shell/alpine-rootfs` (rooted chroot OK).
- Data: `/sdcard/gentoo/{distfiles,logs}`.
- Pending: run Prefix bootstrap with `EPREFIX=/data/local/tmp/gentoo` (base packages installed).

Resume Commands
- Bootstrap: `EPREFIX=/data/local/tmp/gentoo DISTDIR=/sdcard/gentoo/distfiles scripts/rooted-alpine-chroot.sh --cmd "bash -lc 'cd /root && curl -fsSL https://gitweb.gentoo.org/repo/proj/prefix.git/plain/scripts/bootstrap-prefix.sh > bootstrap-prefix.sh && chmod +x bootstrap-prefix.sh && env EPREFIX=/data/local/tmp/gentoo ./bootstrap-prefix.sh'"`.
- Enter shell: `scripts/rooted-alpine-chroot.sh --shell`.
