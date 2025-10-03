06. What I Prepared For The Rooted Chroot

Because the device is rooted, I outlined a chroot path that avoids proot overhead. I documented how I would extract Alpine to `/data/local/alpine`, mount `/proc`, `/sys`, `/dev`, and `/dev/pts`, and chroot.

I noted that some LineageOS builds deny `sys_chroot` even with root, so I included temporary (non‑persistent) Magisk policy commands to allow it for the session. For persistence, I would package those rules in a tiny Magisk module.

Inside the chroot, I would install build tools with `apk`, then run the Gentoo Prefix bootstrap with `EPREFIX=/data/local/gentoo`. I kept this optional because the ADB‑only/native toolchain path was progressing well.

