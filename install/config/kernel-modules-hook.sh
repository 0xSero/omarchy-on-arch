# omarchy-on-arch: starting the cleanup now is only a convenience (it runs at
# every boot anyway), so don't let a failed start abort the install.
chrootable_systemctl_enable linux-modules-cleanup.service || sudo systemctl enable linux-modules-cleanup.service
