# Codex Installers ✨

Remote‑first installers and runbooks for automating Gentoo (and other OS/prefix) installs over SSH — on modern and legacy hardware. These are repeatable, scriptable approaches to bootstrap systems without physical access, with safety‑minded practices throughout.

**Why this exists:** make remote installs predictable, safe, and shareable.

## Table of Contents
- [🚀 Overview](#-overview)
- [💡 Why This Helps](#-why-this-helps)
- [📦 What’s Inside](#-whats-inside)
- [🧭 Use Cases](#-use-cases)
- [📊 Status](#-status)
- [⚡ Quickstart](#-quickstart)
- [🧱 Design Principles](#-design-principles)
- [🗂️ Repository Layout](#️-repository-layout)
- [🛡️ Safety & Hygiene](#-safety--hygiene)
- [🗺️ Roadmap](#-roadmap)
- [🤝 Contributing](#-contributing)
- [🗨️ Questions](#-questions)

---

## 🚀 Overview
- Remote, SSH/ADB‑driven installers and runbooks for diverse hardware.
- Emphasis on resilience (tmux, logs), idempotence, and explicit confirmation.
- Focus on strange or under‑documented platforms where repeatability matters.

## 💡 Why This Helps
- **Repeatable remote installs:** turn ad‑hoc SSH sessions into documented, idempotent steps you can trust and reuse.
- **Safer destructive steps:** explicit target confirmation, UUIDs in `fstab`, tmux/logging guidance to survive disconnects.
- **Weird and vintage targets:** x32 iMacs with 32‑bit EFI, Android ADB‑only, PowerPC MorphOS, classic Mac OS 9, Amiga, PSP.
- **Prefix everywhere:** Gentoo Prefix on constrained or locked‑down systems (Android, macOS, maybe MorphOS) for a familiar userland.

## 📦 What’s Inside
- **Root guidance:** repo‑wide practices in `AGENTS.md` (safety, large artifacts, remote session hygiene).
- **Sub‑installers:** device‑specific runbooks under `installer-*/AGENTS.md`.
- **Automation:** scripts to drive remote installs via SSH/ADB where appropriate.
- **Documentation:** notes and logs to capture outcomes and gotchas.

## 🧭 Use Cases
- Install Gentoo on a laptop remotely over SSH from a live environment.
- Bootstrap **Gentoo Prefix on Android** via ADB only, staging executables on exec‑capable paths and data on `/sdcard`.
- Bring up **x32 systemd Gentoo** on a 2007 iMac with 32‑bit EFI and dual BIOS/EFI GRUB.
- Explore prefix‑style dev on **MorphOS PowerBooks** via SSH for better toolchain and scripting.
- Repair broken **macOS Sequoia Prefix** flows and document workarounds.
- Prototype on very old or unusual targets (DOS, Mac OS 9, AmigaOS 1.x, PSP) with clear constraints.

## 📊 Status
- Android (ADB‑only) prefix/bootstrap: **active** — exec on `/data/local/tmp`, data on `/sdcard`; `proot` or `chroot` based on SELinux/root.
- Dell E6540 (amd64): **complete** — step‑by‑step remote Gentoo via SSH, systemd, UEFI GRUB, optional encrypted `/home`.
- iMac A1228 (x32 systemd): **complete** — GPT, dual BIOS/EFI GRUB, swap file for low‑RAM systems.
- macOS Sequoia Prefix: **planned** — track breakages and provide reproducible bootstrap.
- MorphOS (PowerBook): **planned** — SSH workflow eval and prefix‑like dev environment.
- Legacy targets (DOS/MacOS9/Amiga/PSP): **exploratory** — feasibility and tooling notes.

## ⚡ Quickstart
1) Read repo root guidance: `AGENTS.md`.
2) Pick a subproject runbook.

### Subprojects
   - 🟢 Android ADB Prefix: `installer-android-gentoo-prefix/AGENTS.md`
   - 💻 Dell E6540: `installer-dell-e6540/AGENTS.md`
   - 🍎 iMac A1228: `installer-imac/AGENTS.md`
3) Follow the runbook exactly. Start `tmux` after SSH, enable `script -aq /root/install.log` if possible, and explicitly confirm destructive targets.
4) Keep notes in the appropriate subdirectory; prefer small, frequent updates.

## 🧱 Design Principles
- **Remote‑first and resilient:** assume SSH/ADB with possible disconnects (tmux + logs).
- **Idempotent steps:** clear inputs/outputs; safe reruns where possible.
- **Explicit confirmation:** never guess disks/targets; require confirmation before destructive actions.
- **Minimal assumptions:** favor distro kernels and standard tooling; document deviations.
- **No giant binaries in Git:** ignore toolchains/build outputs; publish artifacts via releases/external storage.

## 🗂️ Repository Layout
- `AGENTS.md` — repo‑wide guidance (scope, safety, large artifacts, sessions, docs/logs pattern).
- `installer-android-gentoo-prefix/` — ADB‑only bootstrap and prefix experiments for Android.
- `installer-dell-e6540/` — Remote Gentoo install plan for Latitude E6540.
- `installer-imac/` — Remote Gentoo install plan for iMac A1228 (x32 systemd, dual boot flow).
- `.gitignore` — excludes heavy paths (toolchains, builds, images, temp ESPs).

## 🛡️ Safety & Hygiene
- **Destructive steps labeled:** scripts/runbooks require explicit device confirmation (e.g., `/dev/sda`).
- **Session resilience:** use `tmux`; optionally keep a transcript with `script -aq /root/install.log`.
- **Stable mounts:** prefer UUIDs in `/etc/fstab` and `/etc/crypttab`.

### Public Repo Hygiene
- Do not commit secrets, keys, or passwords.
- LAN IPs in the `192.168.1.x` range are fine in examples/logs.
- Large outputs/toolchains must not be committed; add heavy paths to `.gitignore` and reference from docs/releases.

## 🗺️ Roadmap
- macOS Sequoia: repair Gentoo Prefix bootstrap, track issues/workarounds, provide a minimal reproducible script.
- MorphOS on PowerBook: SSH access patterns, packaging a familiar shell/coreutils/dev tooling; evaluate prefix viability.
- Android ADB‑only: stable aarch64 `proot`/`chroot` path with SELinux policy guidance; host‑built toolchain staging.
- Legacy targets: document constraints and bootstrap options (cross‑compiled toolchains, emulators, prefix‑like layers).

## 🤝 Contributing
- Open an issue describing the target, constraints, and minimal remote access available.
- Follow `AGENTS.md` conventions for scripts (`set -euo pipefail`, idempotence) and docs (small, frequent updates).
- If your workflow creates a new heavy output path, extend `.gitignore` and mention it in `AGENTS.md`.

## 🗨️ Questions
- Any platforms you want prioritized for remote‑first bootstraps (MorphOS, macOS Prefix fixes, classic/embedded targets)?
