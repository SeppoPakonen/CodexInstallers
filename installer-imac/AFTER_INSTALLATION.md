# After Installation Playbook

1. **Install helper tooling**
   - `emerge --ask sys-apps/bpftrace net-firewall/iptables net-analyzer/wireshark net-wireless/rtl-sdr media-radio/gqrx app-misc/usbip` as desired.
2. **Dynamic debug quickstart**
   - Mount debugfs if needed: `mount -t debugfs none /sys/kernel/debug`.
   - Enable verbose USB logs on demand: `echo 'module usbcore +p' > /sys/kernel/debug/dynamic_debug/control`.
3. **Clone packets with TEE**
   - Load the module: `modprobe xt_TEE`.
   - Mirror ingress to a sniffer box: `iptables -t mangle -A PREROUTING -j TEE --gateway 192.168.1.50`.
4. **BPF tracing session**
   - Verify JIT is active: `cat /proc/sys/net/core/bpf_jit_enable` (expect `1`).
   - Run a sample trace: `bpftrace -e 'tracepoint:syscalls:sys_enter_execve { @[comm] = count(); }'`.
5. **RTL-SDR / DVB-T workflow**
   - `modprobe dvb_usb_rtl28xxu rtl2832` to pull in the stick drivers.
   - Confirm with `lsusb` and scan frequencies using `rtl_power` or tune via `gqrx`.
6. **USB audio toys**
   - `modprobe snd-usb-audio` (others auto-load from aliases).
   - Route audio with PipeWire/ALSA, or capture raw PCM with `arecord -D hw:1,0`.
7. **USB/IP remoting**
   - Start the daemon: `modprobe usbip_core usbip_host; usbipd -D`.
   - Attach a remote device: `usbip attach -r <server-ip> -b <busid>`.
8. **Scripted input hijinks**
   - Load the driver: `modprobe uinput`.
   - Use `python-evdev` or `uinput` utilities to emit keystrokes and joystick events.
9. **Wiimote pairing**
   - `modprobe hid-wiimote` then pair via `bluetoothctl` and map buttons with `xwiimote` tools.
10. **Next-wave features to consider**
    - USB gadget fuzzing (ConfigFS), packet generator (`pktgen`), LED trigger experiments.

Happy hacking!
