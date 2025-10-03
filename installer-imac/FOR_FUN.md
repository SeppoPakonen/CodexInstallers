# Kernel Toys Enabled So Far

- **Dynamic debug switches** (`CONFIG_DYNAMIC_DEBUG`)
  - Toggle kernel `pr_debug()` statements at runtime with `echo 'module usbcore +p' > /sys/kernel/debug/dynamic_debug/control` and watch the logs light up.
- **Packet teeing for mirroring hijinks** (`CONFIG_NETFILTER_XT_TARGET_TEE=m`)
  - Mirror live traffic with an iptables/nftables rule such as `iptables -t mangle -A PREROUTING -j TEE --gateway 192.168.1.50` and inspect it elsewhere.
- **eBPF tracing playground** (`CONFIG_BPF*` with JIT)
  - Pair with `bpftrace` inside the finished install to script on-the-fly observability (syscall heatmaps, scheduling graphs, etc.).
- **RTL-SDR / DVB-T lab** (`CONFIG_DVB_USB_RTL28XXU=m`, SDR + tuner modules)
  - Plug in an RTL2832U stick, load modules with `modprobe dvb_usb_rtl28xxu`, and jump into `rtl_tcp`, `gqrx`, or your favorite SDR playground.
- **USB audio gadgets** (`CONFIG_SND_USB_*` as modules)
  - Drop in any class-compliant USB DAC/ADC or quirky Line6 interface; modules (`snd-usb-audio`, etc.) are ready to modprobe.
- **Virtual USB tunneling** (`CONFIG_USBIP_CORE`, `CONFIG_USBIP_VHCI_HCD`, `CONFIG_USBIP_HOST`)
  - Export or import USB devices across the LAN with `usbipd`/`usbip attach` for remote play.
- **Virtual input generator** (`CONFIG_INPUT_UINPUT=m`)
  - Script keyboard/mouse/gamepad events from user space to prank or automate.
- **Nintendo Wiimote HID** (`CONFIG_HID_WIIMOTE=m`)
  - Pair old Wii controllers as Bluetooth input devices for retro gaming setups.

# Ideas Still On Deck

- **USB gadget fuzzing** (e.g., `CONFIG_USB_F_UAC2`, `CONFIG_USB_CONFIGFS_F_*`)
- **In-kernel packet generators** (`CONFIG_NET_PKTGEN`)
- **LED trigger fun** (`CONFIG_LEDS_TRIGGERS`, breathing/disk activity light shows)
