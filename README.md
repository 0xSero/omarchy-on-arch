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
| `error: target not found: omarchy-walker`. The package was removed from the Omarchy repo. | `install/omarchy-base.packages` installs `walker` instead. |
| Elephant (Walker's backend) is no longer published either. | `install/first-run/elephant.sh` skips it when it's missing. |
| 3.8.5 is end-of-life. | `install/post-install/upgrade-to-quattro.sh` runs `omarchy-upgrade-to-quattro` (updated to the upstream `v4-5-1` copy) before the first reboot, so you boot straight into current Omarchy 4.x. Set `OMARCHY_SKIP_QUATTRO=1` to stay on 3.8.5. Not recommended: the app launcher won't work without Elephant. |

Everything else is upstream 3.8.5 unchanged (basecamp/omarchy@f4378f0d). See the commit history.

## If it fails

The installer shows the failed step. Choose **View full log**, or read
`/var/log/omarchy-install.log`, and open an issue with the last screen of it.

## License

Omarchy is released under the [MIT License](https://opensource.org/licenses/MIT), copyright
David Heinemeier Hansson. The patches in this repo are under the same license.
