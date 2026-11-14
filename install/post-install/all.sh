run_logged $OMARCHY_INSTALL/post-install/pacman.sh
source $OMARCHY_INSTALL/post-install/allow-reboot.sh

# omarchy-on-arch: the quattro upgrade replaces ~/.local/share/omarchy with the
# package-backed layout, so keep a copy of the finish screen to run afterwards.
OMARCHY_FINISHED_SCRIPT=$(mktemp)
cp $OMARCHY_INSTALL/post-install/finished.sh "$OMARCHY_FINISHED_SCRIPT"
run_logged $OMARCHY_INSTALL/post-install/upgrade-to-quattro.sh

source "$OMARCHY_FINISHED_SCRIPT"
