# omarchy-on-arch: the 3.8.5 base this installer lays down is only a stepping
# stone. Upgrade straight to the current package-backed Omarchy (4.x) with
# upstream's own upgrader, before the first reboot.
if [[ -n ${OMARCHY_SKIP_QUATTRO:-} ]]; then
  echo "OMARCHY_SKIP_QUATTRO set; staying on Omarchy 3.8.5"
  exit 0
fi

# Run as root: as a user the upgrader calls `sudo -v`, whose password prompt
# would be hidden inside the install log. As root it uses the same cached sudo
# credentials as every other install step.
sudo "$OMARCHY_PATH/bin/omarchy-upgrade-to-quattro" --yes --channel stable --user "$USER"
