#!/usr/bin/env bash
# Install the script and systemd user units, then enable them.
set -euo pipefail
cd "$(dirname "$0")"

install -Dm755 krdp-display-switch "$HOME/.local/bin/krdp-display-switch"
install -Dm644 -t "$HOME/.config/systemd/user" systemd/krdp-display-switch.service systemd/krdp-display-switch-start.timer

systemctl --user daemon-reload
systemctl --user enable krdp-display-switch.service krdp-display-switch-start.timer
systemctl --user start krdp-display-switch-start.timer
# Start now if inside the time window (ExecCondition skips it otherwise)
systemctl --user start krdp-display-switch.service || true
systemctl --user --no-pager status krdp-display-switch.service | head -3
