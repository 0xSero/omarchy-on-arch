# omarchy-on-arch: the 3.8.5 base this installer lays down is only a stepping
# stone. Upgrade straight to the current package-backed Omarchy (4.x) with
# upstream's own upgrader, before the first reboot.
if [[ -n ${OMARCHY_SKIP_QUATTRO:-} ]]; then
  echo "OMARCHY_SKIP_QUATTRO set; staying on Omarchy 3.8.5"
  exit 0
fi

"$OMARCHY_PATH/bin/omarchy-upgrade-to-quattro" --yes --channel stable --user "$USER"
