# omarchy-on-arch

Install [Omarchy](https://omarchy.org) on top of an existing vanilla Arch Linux install, the old
"curl | bash" way.

Upstream Omarchy now installs only from its ISO. Its previous online installer (the `master`
branch of [basecamp/omarchy](https://github.com/basecamp/omarchy), frozen at 3.8.5) no longer
works against today's package repos. This is that installer, patched so it runs again, and it
finishes by upgrading to the current Omarchy release with upstream's own upgrader.

This is an unofficial community patch, not supported by Basecamp or the Omarchy project.

## Requirements

The same as the original installer:

- Fresh, vanilla Arch Linux (not Manjaro, CachyOS, EndeavourOS or other derivatives), x86_64
- **Btrfs** root filesystem and the **Limine** bootloader. In `archinstall`, choose Btrfs
  for the filesystem and Limine for the bootloader.
- No GNOME or KDE installed
- Secure Boot turned off
- Logged in as a normal user with sudo, not root

## Install

```bash
curl -fsSL -o ~/boot.sh https://raw.githubusercontent.com/0xSero/omarchy-on-arch/main/boot.sh
bash ~/boot.sh
```

Download the script and then run it, rather than piping it into `bash`, so the installer's
prompts can read your keyboard. When it's done, choose **Reboot Now**.

## What it changes compared with upstream 3.8.5

| Problem | Fix |
|---|---|
| Omarchy pins pacman to a dated snapshot mirror. A freshly installed Arch has *newer* package databases, so `pacman -Syu` says "up to date" and then 404s (for example `git-2.56.1 failed to download`). | `boot.sh` runs `pacman -Syyuu`, which refreshes the databases and allows the downgrade to the snapshot. |
| `error: target not found: omarchy-walker`. The package was removed from the Omarchy repo. | `install/omarchy-base.packages` installs `walker` instead. Elephant, Walker's backend, is gone too, so `install/first-run/elephant.sh` skips it when it's missing. |
| On Dell XPS Panther Lake laptops: `WARNING: No kernel found` / `failed to add boot entries to /boot/limine.conf`. The installer tried to swap in `linux-ptl`, which no longer exists, but removed the stock `linux` kernel anyway. | `install/config/hardware/intel/ptl-kernel.sh` only swaps kernels when `linux-ptl` really installs, and reinstalls `linux` if an earlier run left the machine without a kernel. `install/login/limine-snapper.sh` recovers the kernel cmdline from the running kernel when re-run. |
| `Error: Limine config not found`. Current `archinstall` mounts `/boot` with `dmask=0077`, and the installer read it without `sudo`. | `install/login/limine-snapper.sh` reads `/boot` through `sudo`. |
| 3.8.5 is end-of-life. | `install/post-install/upgrade-to-quattro.sh` runs upstream's `omarchy-upgrade-to-quattro` (the newer `v4-5-1` copy) before the first reboot, so you boot straight into Omarchy 4.x. |
| The upgrader's migrations call `sudo -v` and `systemctl --user` from inside the install log, where a password prompt can't be answered, and it asks its own reboot question nobody can see. | The upgrade runs as root with a temporary `/etc/sudoers.d/99-omarchy-installer`, the same file upstream's ISO installer uses. The file is removed as soon as the step exits. The upgrader is pointed at your user's systemd manager, and the reboot is left to the installer's own **Reboot Now** screen. |
| After the upgrade swaps `~/.local/share/omarchy`, the finish screen and `tte` are gone. | The finish screen is copied before the upgrade and falls back to `gum`. |

Everything else is upstream 3.8.5 unchanged (basecamp/omarchy@f4378f0d). The commit history shows each patch.

## Tested

Tested end to end on 2026-11-14 in a UEFI VM: Arch ISO 2026.11.01 → `archinstall` (Btrfs + Limine,
normal password sudo) → `bash boot.sh` → "Installed in 5m 50s" → **Reboot Now** → Omarchy 4.5.0
(kernel `7.2.15-1-omarchy`), with SDDM autologin into Hyprland and the Omarchy shell running, and
no failed system or user services.

Set `OMARCHY_SKIP_QUATTRO=1` to stop at 3.8.5 instead. That isn't recommended, and it's untested:
the app launcher won't work without Elephant.

## If it fails

The installer shows the failed step. Choose **View full log**, or read
`/var/log/omarchy-install.log`, and open an issue with the last screen of it.

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT), copyright
David Heinemeier Hansson. The patches in this repo are under the same license.
