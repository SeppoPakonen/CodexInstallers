04. How I Built Android Binutils/GCC

I built native Android aarch64 binutils (2.42) and GCC (13.2.0, stage1 C only) using NDK r26b on the host. I wrote `scripts/build-android-toolchain.sh` to automate fetching, retrying on flaky downloads, configuring, and installing into `builds/out-run-bin/` so I could ADB‑push the results.

To avoid Android‑specific headers breaking host builds, I kept host `CFLAGS` generic and set NDK sysroot only in `CFLAGS_FOR_TARGET` and `LDFLAGS_FOR_TARGET`. I disabled components that aren’t needed or don’t build cleanly on Android (gdb, gdbserver, sim, gprofng).

I verified the result on device by running `/data/local/tmp/run-bin/bin/ld -v`, which reported GNU ld 2.42. When the network glitched, I re‑ran the script; it resumes cleanly and re‑downloads corrupt tarballs automatically.

