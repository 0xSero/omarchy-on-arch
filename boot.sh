#!/bin/bash

# omarchy-on-arch: install Omarchy on top of an existing vanilla Arch install.
#
# Upstream Omarchy now only installs from its ISO, and its old online installer
# (basecamp/omarchy master, 3.8.5) no longer works against today's package
# repos. This patched copy installs the 3.8.5 base, then runs upstream's own
# omarchy-upgrade-to-quattro to land on the current package-backed Omarchy.

set -e

# Set install mode to online since boot.sh is used for curl installations
export OMARCHY_ONLINE_INSTALL=true

ansi_art='                 ▄▄▄
 ▄█████▄    ▄███████████▄    ▄███████   ▄███████   ▄███████   ▄█   █▄    ▄█   █▄
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   █▀   ███   ███  ███   ███
███   ███  ███   ███   ███ ▄███▄▄▄███ ▄███▄▄▄██▀  ███       ▄███▄▄▄███▄ ███▄▄▄███
███   ███  ███   ███   ███ ▀███▀▀▀███ ▀███▀▀▀▀    ███      ▀▀███▀▀▀███  ▀▀▀▀▀▀███
███   ███  ███   ███   ███  ███   ███ ██████████  ███   █▄   ███   ███  ▄██   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
 ▀█████▀    ▀█   ███   █▀   ███   █▀   ███   ███  ███████▀   ███   █▀    ▀█████▀
                                       ███   █▀                                  '

clear
echo -e "\n$ansi_art\n"

OMARCHY_REPO="${OMARCHY_REPO:-0xSero/omarchy-on-arch}"
OMARCHY_REF="${OMARCHY_REF:-main}"
OMARCHY_REPO_URL="${OMARCHY_REPO_URL:-https://github.com/${OMARCHY_REPO}.git}"

# Omarchy pins Arch to its own dated snapshot mirror. A freshly installed Arch
# usually has newer package databases than that snapshot, so a plain -Syu
# reports "up to date" and then 404s on packages the snapshot never had.
# Force a refresh (-yy) and allow the downgrade to the snapshot (-uu).
export OMARCHY_MIRROR=stable
echo 'Server = https://stable-mirror.omarchy.org/$repo/os/$arch' | sudo tee /etc/pacman.d/mirrorlist >/dev/null
sudo pacman -Syyuu --noconfirm --needed git

echo -e "\nCloning Omarchy from: ${OMARCHY_REPO_URL}"
echo -e "\e[32mUsing branch: $OMARCHY_REF\e[0m"
rm -rf ~/.local/share/omarchy/
git clone --depth 1 --branch "$OMARCHY_REF" "$OMARCHY_REPO_URL" ~/.local/share/omarchy >/dev/null

echo -e "\nInstallation starting..."
source ~/.local/share/omarchy/install.sh
