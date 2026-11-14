# omarchy-on-arch: an earlier run of the old Dell XPS Panther Lake step could
# remove the stock kernel without installing a replacement. Several config
# steps (kernel-modules-hook, Limine) need a kernel, so put one back first.
if ! compgen -G "/usr/lib/modules/*/modules.builtin" >/dev/null; then
  echo "No kernel installed; installing linux..."
  sudo pacman -S --noconfirm --needed linux linux-headers
fi
