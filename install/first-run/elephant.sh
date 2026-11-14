# Elephant is no longer published in the Omarchy package repo. Skip it when
# missing; the Quattro upgrade replaces Walker/Elephant anyway.
command -v elephant &>/dev/null || exit 0
elephant service enable
systemctl --user start elephant.service
