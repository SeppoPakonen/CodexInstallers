# Agents Guide (Repo Root)

This repository hosts multiple installer projects (Android Gentoo Prefix, Dell E6540, iMac A1228). Use this file for repo‑wide guidance. Task/runbook specifics live in the subdirectories’ AGENTS.md files.

## Quick Links
- [Scope](#scope)
- [Large Artifacts Policy](#large-artifacts-policy)
- [Working Conventions](#working-conventions)
- [Remote Session Practices](#remote-session-practices)
- [Destructive Ops Checklist](#destructive-ops-checklist)
- [Filesystem Identifiers](#filesystem-identifiers)
- [Documentation & Logs](#documentation--logs)
- [Subprojects](#subprojects)
- [Tips](#tips)

## Scope
- Applies to the entire repository unless a deeper `AGENTS.md` states otherwise. Deeper files take precedence for their subtree.

## Large Artifacts Policy
- Do not commit toolchains, build outputs, images, or temporary mounts. These grow to multi‑GB quickly and break clones.
- A root `.gitignore` is provided to exclude known heavy paths:
  - `installer-android-gentoo-prefix/{builds,toolchains,toolchain-android,downloads,trash}`
  - `installer-imac/{rEFIt-0.14*,tmp-esp}`
- If a workflow introduces a new large output path, add it to `.gitignore` and mention it briefly here.
- To share binaries or images, publish via releases or external storage and link from docs instead of committing.

## Working Conventions
- Keep changes focused and small; prefer adding scripts and documentation over committing generated outputs.
- For shell scripts, favor: `set -euo pipefail` and clear, idempotent steps.
- For destructive operations (partitioning, formatting, flashing), require explicit target confirmation in the script or docs.
- Record progress and decisions in Markdown within the relevant installer directory (as the sub‑AGENTS.md files do).

## Remote Session Practices
- Start a resilient shell: use `tmux` after SSH login; if available, keep a transcript with `script -aq /root/install.log` inside tmux.
- Harden the shell for long sessions: run `set -euo pipefail` and `umask 022`.
- Verify basics up front: `date`, `ip a`, `lsblk -o NAME,SIZE,TYPE,MOUNTPOINT`.
- Prefer stable power and wired networking during installs to minimize risk.

## Destructive Ops Checklist
- Confirm the exact target device (e.g., `/dev/sda`, `/dev/nvme0n1`) with:
  - `lsblk -d -o NAME,MODEL,SIZE,ROTA,TYPE` and `blkid`
- Do not proceed if there is any mismatch; require explicit user confirmation of the device path before partitioning/formatting.

## Filesystem Identifiers
- Use UUIDs in `/etc/fstab` (and `/etc/crypttab` when applicable) to avoid device-name drift.

## Documentation & Logs
- Keep progress and decisions up to date in Markdown alongside each installer.
- Optional repo‑wide “Book” pattern (if desired):
  - Dual record under `Book/` for meaningful changes:
    - Human chapter: `Book/%02d - <Title>.md` (narrative), and
    - Agent summary: `Book/<Title>.md` (concise bullets).
  - Maintain a dated changelog: `Book/ChangeLog-YYYY-MM-DD.md`.
  - Favor small, frequent updates to keep reality and docs in sync.

## Subprojects
- `installer-android-gentoo-prefix`: Android device bootstrap and prefix/toolchain experiments. Very large directories are ignored by default.
- `installer-dell-e6540`: Remote Gentoo install plan for Latitude E6540.
- `installer-imac`: Remote Gentoo install plan for iMac A1228 with x32 systemd flow and dual (BIOS/EFI) boot steps.

## Tips
- Use `du -sh *` at repo and subproject roots to monitor growth.
- Prefer path‑specific ignores over global patterns to avoid hiding source accidentally.
- If you need me to run tests or validations, specify commands and any environment constraints.
 - Public hygiene: keeping `192.168.1.x` LAN IPs and real device model names in docs is fine; never commit secrets, keys, or passwords.
