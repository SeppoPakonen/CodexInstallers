# Codex Installers

Remote-first installers and runbooks for automating Gentoo (and other OS/prefix) installs over SSH — on modern and legacy hardware. This repository collects repeatable, scriptable approaches to bootstrap systems without physical access, plus documentation and practices to stay safe while doing so.

Why this helps others
- Repeatable remote installs: Turn ad‑hoc “just SSH in and do it” into documented, idempotent steps you can trust and reuse.
- Safer destructive steps: Partitioning/formatting requires explicit confirmation, UUIDs in fstab, and tmux/logging guidance to survive disconnects.
- Weird and vintage targets: Share hard-won knowledge for platforms with scarce docs (x32 iMacs with 32‑bit EFI, Android ADB‑only, PowerPC MorphOS, classic Mac OS 9, Amiga, PSP).
- Prefix everywhere: Gentoo Prefix bootstraps on constrained or locked‑down systems (Android, macOS, maybe MorphOS) to create a familiar userland without replacing the base OS.

What’s in here
- Root guidance: repo‑wide practices in `AGENTS.md` (safety, large artifacts, remote session hygiene).
- Sub‑installers with device‑specific runbooks under `installer-*/AGENTS.md`.
- Scripts to drive remote installs via SSH/ADB where appropriate.
- Notes and logs that capture outcomes and gotchas so the next run is easier.

Use cases
- Install Gentoo on a laptop remotely over SSH from a live environment.
- Bootstrap Gentoo Prefix on Android via ADB only (no Termux runtime), staging executables on exec‑capable paths and data on `/sdcard`.
- Bring up x32 systemd Gentoo on a 2007 iMac with 32‑bit EFI and dual BIOS/EFI GRUB for maximum boot flexibility.
- Explore prefix‑style development on MorphOS PowerBooks via SSH for a better toolchain and scripting story.
- Repair broken Gentoo Prefix flows on recent macOS (e.g., Sequoia) and document workarounds.
- Experiment with very old or unusual targets (DOS, Mac OS 9, AmigaOS 1.x, Sony PSP) where feasible, documenting constraints and prototypes.

Status at a glance
- Android (ADB‑only) prefix/bootstrap: active experiments; exec on `/data/local/tmp`, data under `/sdcard`; proot or chroot depending on SELinux/root.
- Dell E6540 (amd64): complete step‑by‑step remote Gentoo install via SSH, systemd, UEFI GRUB, optional encrypted `/home`.
- iMac A1228 (x32 systemd): complete runbook with GPT, dual BIOS/EFI GRUB, swap file for low‑RAM systems.
- macOS Sequoia Prefix: planned; known breakages to be investigated and documented with a reproducible bootstrap.
- MorphOS (PowerBook): planned; SSH workflow evaluation + potential prefix‑like environment for dev.
- Legacy targets (DOS/MacOS9/Amiga/PSP): exploratory; feasibility studies and tooling notes to follow.

Quickstart
1) Read repo root guidance: `AGENTS.md`.
2) Pick a subproject and open its runbook:
   - Android ADB prefix: `installer-android-gentoo-prefix/AGENTS.md`
   - Dell E6540: `installer-dell-e6540/AGENTS.md`
   - iMac A1228: `installer-imac/AGENTS.md`
3) Follow the runbook exactly. Start `tmux` after SSH, enable logging if possible, and explicitly confirm any destructive targets.
4) Keep notes in the appropriate subdirectory; prefer small, frequent updates.

Design principles
- Remote‑first and resilient: Always assume SSH/ADB with possible disconnects (tmux + logs).
- Idempotent steps: Clear inputs/outputs; safe re‑runs where possible.
- Explicit confirmation: Never guess disks or targets; require confirmation before destructive actions.
- Minimal assumptions: Favor distribution kernels and standard tooling; document deviations.
- No giant binaries in Git: Ignore toolchains/build outputs; publish artifacts via releases or external storage when needed.

Repository layout
- `AGENTS.md` — repo‑wide guidance: scope, safety, large artifacts policy, session practices, docs/logs pattern.
- `installer-android-gentoo-prefix/` — ADB‑only bootstrap and prefix experiments for Android.
- `installer-dell-e6540/` — Remote Gentoo install plan for Latitude E6540.
- `installer-imac/` — Remote Gentoo install plan for iMac A1228 (x32 systemd, dual boot flow).
- `.gitignore` — excludes heavy paths (toolchains, builds, images, temp ESPs) to keep clones sane.

Safety and approvals
- Destructive steps are labeled; scripts/runbooks require explicit device confirmation (e.g., `/dev/sda`).
- Use `tmux` and optionally `script -aq /root/install.log` to survive disconnects and keep a transcript.
- Prefer UUIDs in `/etc/fstab` and `/etc/crypttab`.

 Public repo hygiene
 - Do not commit secrets, keys, or passwords. LAN IPs in the `192.168.1.x` range are fine to keep in examples and logs.
 - Large outputs and toolchains must not be committed; add any new heavy paths to `.gitignore` and reference from docs/releases.

Roadmap
- macOS Sequoia: repair Gentoo Prefix bootstrap, track issues/workarounds, provide a minimal reproducible script.
- MorphOS on PowerBook: SSH access patterns, packaging a familiar shell/coreutils/dev tooling; evaluate prefix viability.
- Android ADB‑only: stable aarch64 proot or chroot path with SELinux policy guidance; host‑built toolchain staging.
- Legacy targets: document constraints and bootstrap options (e.g., cross‑compiled toolchains, emulators, or prefix‑like layers).

Contributing
- Start by opening an issue describing the target, constraints, and the minimal remote access you have.
- Follow `AGENTS.md` conventions for scripts (set -euo pipefail, idempotence) and docs (small, frequent updates).
- If your workflow creates a new heavy output path, extend `.gitignore` and mention it in `AGENTS.md`.

 Questions for users and collaborators
 - Any platforms you want prioritized for remote‑first bootstraps (MorphOS, macOS Prefix fixes, classic/embedded targets)?
