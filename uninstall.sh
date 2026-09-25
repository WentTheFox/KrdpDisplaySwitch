#!/usr/bin/env bash
# Stop and remove the units and script. Stopping the service restores the layout.
set -euo pipefail

systemctl --user disable --now krdp-display-switch-start.timer krdp-display-switch.service 2>/dev/null || true
rm -f "$HOME/.local/bin/krdp-display-switch" \
      "$HOME/.config/systemd/user/krdp-display-switch.service" \
      "$HOME/.config/systemd/user/krdp-display-switch-start.timer"
rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/krdp-display-switch"
systemctl --user daemon-reload
