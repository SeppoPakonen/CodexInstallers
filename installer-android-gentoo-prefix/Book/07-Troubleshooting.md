07. How I Solved Issues

When downloads stalled or corrupted, I retried with the builder’s fetch logic. When binutils failed in gprofng on Android (pthread cancel state), I rebuilt with `--disable-gprofng --disable-gdb --disable-gdbserver --disable-sim`.

When GCC complained about missing `asm/types.h`, I realized the host build had leaked target sysroot into host CFLAGS. I fixed it by keeping host `CFLAGS` generic and moving Android specifics into `*_FOR_TARGET` variables.

When `ld` wasn’t found at `/data/local/tmp/run-bin/ld`, I checked the install path and used `/data/local/tmp/run-bin/bin/ld` instead. For `/sdcard` exec problems, I always invoked scripts with explicit interpreters from the exec area.

