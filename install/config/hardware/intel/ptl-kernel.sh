# Install Panther Lake kernel for Dell XPS Panther Lake systems
# The linux-ptl kernel includes audio driver patches not yet in mainline.
#
# omarchy-on-arch: linux-ptl has since been dropped from the Omarchy repo (its
# patches live on in linux-omarchy, which the quattro upgrade installs). The
# old script removed `linux` even when linux-ptl failed to install, leaving the
# machine with no kernel at all. Only swap kernels when linux-ptl really
# installed, and always make sure some kernel is present before moving on.

ptl_dropin=/etc/limine-entry-tool.d/dell-xps-panther-lake.conf

if omarchy-hw-match "XPS" && omarchy-hw-intel-ptl && pacman -Si linux-ptl &>/dev/null; then
  echo "Detected Dell XPS Panther Lake, installing PTL kernel..."

  if omarchy-pkg-add linux-ptl linux-ptl-headers; then
    for pkg in linux linux-headers; do
      sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    done

    sudo mkdir -p /etc/limine-entry-tool.d
    cat <<EOF | sudo tee "$ptl_dropin" >/dev/null
# Only show Panther Lake kernel in boot menu on Dell XPS Panther Lake
BOOT_ORDER="linux-ptl*, *fallback, Snapshots"
EOF
  fi
fi

# Never boot-order around a kernel that isn't installed
if ! pacman -Q linux-ptl &>/dev/null; then
  sudo rm -f "$ptl_dropin"
fi

# Repair machines where an earlier run removed `linux` without a replacement
if ! compgen -G "/usr/lib/modules/*/modules.builtin" >/dev/null; then
  echo "No kernel installed; installing linux..."
  sudo pacman -S --noconfirm --needed linux linux-headers
fi
