#!/bin/bash

# omarchy-on-arch: resume after the final "upgrade to Omarchy 4" step failed.
# Everything before that step is already done, so don't re-run the whole
# installer over a half-upgraded system: fetch the latest patched upgrader and
# run just that step again. Upstream's upgrader is safe to re-run.

set -e

OMARCHY_REPO_URL="${OMARCHY_REPO_URL:-https://github.com/0xSero/omarchy-on-arch.git}"
OMARCHY_REF="${OMARCHY_REF:-main}"

src=$(mktemp -d)
git clone --depth 1 --branch "$OMARCHY_REF" "$OMARCHY_REPO_URL" "$src" >/dev/null
export OMARCHY_PATH="$src"

sudo -v
bash "$src/install/post-install/upgrade-to-quattro.sh"

echo
echo -e "\e[32mOmarchy upgrade complete.\e[0m"
read -rp "Reboot now? [Y/n] " answer
[[ ${answer,,} == n* ]] || sudo reboot
