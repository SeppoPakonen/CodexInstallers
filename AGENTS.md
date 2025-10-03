# Agents Guide (Repo Root)

This repository hosts multiple installer projects (Android Gentoo Prefix, Dell E6540, iMac A1228). Use this file for repo‑wide guidance. Task/runbook specifics live in the subdirectories’ AGENTS.md files.

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

## Subprojects
- `installer-android-gentoo-prefix`: Android device bootstrap and prefix/toolchain experiments. Very large directories are ignored by default.
- `installer-dell-e6540`: Remote Gentoo install plan for Latitude E6540.
- `installer-imac`: Remote Gentoo install plan for iMac A1228 with x32 systemd flow and dual (BIOS/EFI) boot steps.

## Tips
- Use `du -sh *` at repo and subproject roots to monitor growth.
- Prefer path‑specific ignores over global patterns to avoid hiding source accidentally.
- If you need me to run tests or validations, specify commands and any environment constraints.
