# omarchy-on-arch: the 3.8.5 base this installer lays down is only a stepping
# stone. Upgrade straight to the current package-backed Omarchy (4.x) with
# upstream's own upgrader, before the first reboot.
if [[ -n ${OMARCHY_SKIP_QUATTRO:-} ]]; then
  echo "OMARCHY_SKIP_QUATTRO set; staying on Omarchy 3.8.5"
  exit 0
fi

# Migrations run as the user under a fresh sudo session and call `sudo -v`,
# which re-prompts for the password partway through the upgrade (the asdcontrol
# rule installed earlier makes even NOPASSWD users authenticate for -v). Grant
# temporary passwordless sudo for the upgrade, the same way upstream's ISO
# installer does with this same file, and always remove it afterwards.
installer_sudoers=/etc/sudoers.d/99-omarchy-installer
cleanup_installer_sudoers() {
  sudo rm -f "$installer_sudoers"
}
trap cleanup_installer_sudoers EXIT

sudo tee "$installer_sudoers" >/dev/null <<EOF
Defaults:$USER verifypw = any
$USER ALL=(ALL) NOPASSWD: ALL
EOF
sudo chmod 440 "$installer_sudoers"
sudo visudo -cq -f "$installer_sudoers"

# Run as root: as a user the upgrader calls `sudo -v` itself, whose password
# prompt would be hidden inside the install log.
sudo env OMARCHY_UPGRADE_DEFER_REBOOT=1 "$OMARCHY_PATH/bin/omarchy-upgrade-to-quattro" --yes --channel stable --user "$USER"
upgrade_status=$?

# omarchy-on-arch: archinstall's "NetworkManager (iwd backend)" option writes
# wifi.backend=iwd into NetworkManager's config. The upgrade retires iwd, which
# leaves the Wi-Fi card "unavailable" after reboot. Fall back to NetworkManager's
# default backend (wpa_supplicant, a hard dependency) whenever iwd is gone.
if ! pacman -Q iwd &>/dev/null; then
  for conf in /etc/NetworkManager/conf.d/*.conf /etc/NetworkManager/NetworkManager.conf; do
    if sudo grep -qE '^[[:space:]]*wifi\.backend[[:space:]]*=[[:space:]]*iwd' "$conf" 2>/dev/null; then
      sudo sed -i -E '/^[[:space:]]*wifi\.backend[[:space:]]*=[[:space:]]*iwd/d' "$conf"
      echo "Removed wifi.backend=iwd from $conf"
    fi
  done
fi

exit $upgrade_status
