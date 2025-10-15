# Post-Installation Configuration - Compaq Mini 900

## Initial System Setup
After successful installation, these steps should be performed:

### 1. Basic System Configuration
- Set root password: `passwd`
- Create regular user account: `useradd -m -G users,wheel,audio,video -s /bin/bash username`
- Set user password: `passwd username`
- Configure hostname in /etc/hostname

### 2. Network Configuration
- Configure network interface in /etc/conf.d/net (if not using DHCP)
- Set up DNS in /etc/resolv.conf
- Enable networking service: `rc-update add net.eth0 default`

### 3. Timezone and Locale
- Set timezone: `ln -sf /usr/share/zoneinfo/Region/City /etc/localtime`
- Configure locales in /etc/locale.gen and run `locale-gen`
- Set system locale in /etc/env.d/02locale

### 4. Hardware-Specific Optimizations
#### Power Management
- Install powertop: `emerge sys-power/powertop`
- Install laptop-mode-tools: `emerge sys-power/laptop-mode-tools`
- Configure CPU frequency scaling: `emerge sys-power/cpupower`
- Enable acpid: `rc-update add acpid default`

#### Graphics
- Install Intel drivers: `emerge x11-drivers/xf86-video-intel`
- Configure X11 for Intel GMA 950
- Consider lightweight desktop environment (XFCE, LXDE)

### 5. Desktop Environment Options
For the Compaq Mini 900's hardware constraints:
- **XFCE**: Good balance of features and performance
- **LXDE**: Very lightweight, good for limited resources
- **Openbox**: Minimal window manager, maximum control
- **Avoid**: KDE5, GNOME3, or other heavy desktops

### 6. Audio Configuration
- Install ALSA: `emerge media-sound/alsa-utils`
- Enable ALSA: `rc-update add alsasound boot`
- Test audio: `speaker-test -c 2`

### 7. Printing and Scanning (if needed)
- CUPS for printing: `emerge cups`
- SANE for scanning: `emerge sane-backends`

### 8. Wireless Configuration (if applicable)
- Identify WiFi hardware with `lspci | grep -i network`
- Install appropriate firmware package
- Configure wpa_supplicant or similar
- Install networkmanager for desktop or wpa_cli for console

### 9. System Monitoring
- Install htop: `emerge app-misc/htop`
- Install smartmontools for drive health: `emerge smartmontools`
- Configure powertop for power analysis

### 10. Security Considerations
- Configure firewall (iptables)
- Disable SSH password login in /etc/ssh/sshd_config
- Consider fail2ban: `emerge net-analyzer/fail2ban`
- Regular updates with `emerge --sync && emerge -uDNav @world`

### 11. Performance Optimizations
- Consider adding tmpfs mounts for /tmp, /var/tmp, /var/log to reduce disk writes
- Configure zram for additional swap space if needed
- Use conservative CPU governor settings
- Disable unnecessary services in OpenRC

### 12. Backup Strategy
- Set up automated backups to external location if possible
- Keep configuration backups
- Consider creating recovery image

### 13. Testing
- Reboot to verify bootloader works
- Test WiFi connectivity if applicable
- Verify all hardware components function
- Test power management features
- Verify all user accounts work properly