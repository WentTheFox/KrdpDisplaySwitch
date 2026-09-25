# krdp-display-switch

KDE's built-in RDP server (`krdpserver`) streams the whole Plasma workspace, so
with several monitors the client gets one very wide, unreadable picture. This
user service watches for RDP connections and, while one is active, switches the
machine to a **single 1920x1080 display**. When the client disconnects, the
previous monitor layout is restored.

## How it works

- Every 2 s it checks `ss` for an established TCP connection on port 3389
  owned by `krdpserver`.
- **On connect:** saves the current layout (enabled state, mode, position and
  priority of every connected output) to
  `~/.local/state/krdp-display-switch/layout`, disables every output except the
  priority-1 (primary) one, and sets that to 1920x1080 (refresh rate closest to
  60 Hz) with `kscreen-doctor`.
- **On disconnect:** once the connection has been gone for 5 s (so brief
  reconnects don't cause flicker), restores the saved layout.
- **Stopping the service** during a session also restores the layout.

### Schedule

It only runs **Monday–Friday, 09:00–17:30**:

- `krdp-display-switch-start.timer` starts the service at 09:00 on weekdays.
- The service starts with the Plasma session too, but its `ExecCondition`
  (`krdp-display-switch --check-window`) stops it from starting outside those
  hours.
- After 17:30 the script exits on its own, but only once no RDP session is
  active. A session that runs past 17:30 keeps its 1080p layout until the client
  disconnects. Then the layout is restored and the service exits.

## Requirements

- KDE Plasma (Wayland) with `krdpserver` enabled (System Settings → Remote Desktop)
- `kscreen-doctor` (part of `libkscreen`), `jq`, `ss` (`iproute2`), `bash`, systemd user session

## Setup

```sh
git clone <this repo> ~/git/krdp-display-switch
cd ~/git/krdp-display-switch
./install.sh
```

This installs:

| File | Destination |
| --- | --- |
| `krdp-display-switch` | `~/.local/bin/` |
| `systemd/krdp-display-switch.service` | `~/.config/systemd/user/` (enabled for `plasma-workspace.target`) |
| `systemd/krdp-display-switch-start.timer` | `~/.config/systemd/user/` (enabled for `timers.target`) |

To change the resolution, port, poll interval or time window, edit the variables
and `in_window()` at the top of `krdp-display-switch`, then run `./install.sh` again.

## Useful commands

```sh
journalctl --user -u krdp-display-switch -f       # watch switches/restores
systemctl --user list-timers 'krdp-*'             # next scheduled start
krdp-display-switch --check-window; echo $?       # 0 = inside time window
```

If the saved layout ever needs restoring by hand (e.g. after a crash), start and
stop the service. A leftover `layout` file is treated as an active session and
is restored on stop.

## Uninstall

```sh
./uninstall.sh
```
