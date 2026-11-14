stop_install_log

echo_in_style() {
  if command -v tte &>/dev/null; then
    echo "$1" | tte --canvas-width 0 --anchor-text c --frame-rate 640 print
  else
    gum style --foreground 2 --padding "0 0 0 $PADDING_LEFT" "$1"
  fi
}

clear
echo
# omarchy-on-arch: tte is gone after the quattro upgrade; fall back to plain output
if command -v tte &>/dev/null && [[ -f ~/.local/share/omarchy/logo.txt ]]; then
  tte -i ~/.local/share/omarchy/logo.txt --canvas-width 0 --anchor-text c --frame-rate 920 laseretch
elif [[ -f /usr/share/omarchy/logo.txt ]]; then
  gum style --foreground 2 --padding "0 0 0 $PADDING_LEFT" "$(</usr/share/omarchy/logo.txt)"
fi
echo

# Display installation time if available
if [[ -f $OMARCHY_INSTALL_LOG_FILE ]] && grep -q "Total:" "$OMARCHY_INSTALL_LOG_FILE" 2>/dev/null; then
  echo
  TOTAL_TIME=$(tail -n 20 "$OMARCHY_INSTALL_LOG_FILE" | grep "^Total:" | sed 's/^Total:[[:space:]]*//')
  if [[ -n $TOTAL_TIME ]]; then
    echo_in_style "Installed in $TOTAL_TIME"
  fi
else
  echo_in_style "Finished installing"
fi

if sudo test -f /etc/sudoers.d/99-omarchy-installer; then
  sudo rm -f /etc/sudoers.d/99-omarchy-installer &>/dev/null
fi

# Exit gracefully if user chooses not to reboot
if gum confirm --padding "0 0 0 $((PADDING_LEFT + 32))" --show-help=false --default --affirmative "Reboot Now" --negative "" ""; then
  # Clear screen to hide any shutdown messages
  clear

  if [[ -n ${OMARCHY_CHROOT_INSTALL:-} ]]; then
    touch /var/tmp/omarchy-install-completed
    exit 0
  else
    sudo reboot 2>/dev/null
  fi
fi
