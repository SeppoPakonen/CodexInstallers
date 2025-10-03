02. How I Worked ADB‑Only

I committed to an ADB‑only flow (no Termux runtime). I wrote `scripts/adb-setup.sh` to create device directories, push a static bash, optionally push `proot.aarch64`, and (if present) extract the Alpine minirootfs into an exec‑capable path.

I used `scripts/push-run-bin.sh` to sync host‑built tools from `builds/out-run-bin` into `/data/local/tmp/run-bin`. I validated the setup by running:
- `/data/local/tmp/run-bin/bash --version`
- `/data/local/tmp/run-bin/bin/ld -v`

I documented that executing directly from `/sdcard` fails (noexec) and that invoking a script via `sh /sdcard/...` works but may drop positional arguments under toybox `sh`. I therefore kept all launchers in the exec area and used absolute interpreters for anything stored on `/sdcard`.

