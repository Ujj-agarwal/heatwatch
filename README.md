# heatwatch

Watches what is loading this Mac every 30 minutes, and when it's bad, writes down exactly
which process is responsible and which Claude session or app started it. `explain` asks
Claude (Haiku, through your logged-in Claude Code account) for a short cause and fix.

Plain bash, using only tools that ship with macOS plus the `claude` CLI.

## Commands

`hw` is short for `heatwatch`.

| Command | What it does |
|---|---|
| `hw` | Status: live load, swap, battery, busiest processes, today's timeline, the last problem |
| `hw log [N]` | The last N snapshots (default 16, about 8 hours) |
| `hw reports` | WARN/BAD reports, newest first, numbered |
| `hw report [N]` | Show report N from that list (default 1 = newest), or by time: `hw report 1623` |
| `hw explain [N]` | Claude names the cause and the fix for report N (cached, so asking again is free) |
| `hw explain N --fresh` | Ask again, ignoring the cache |
| `HEATWATCH_MODEL=sonnet hw explain N` | A deeper read with a bigger model |
| `hw now` | Take a snapshot right now (takes 10 s) |
| `hw help` | This list |

## States

- **BAD**: the machine is overloaded and will heat. Load above 2× cores, one process using
  2.5+ cores, heavy swapping, or a thermal warning. Also sends a macOS notification.
- **WARN**: getting there. Load above cores, swap 85%+ full, `kernel_task` 40%+, or a process
  pinned at a full core for over an hour (likely stuck or orphaned).
- **OK**: none of the above.

## Files

| Path | What |
|---|---|
| `bin/heatwatch` | The whole tool |
| `launchd/com.ujjwal.heatwatch.plist` | Runs `heatwatch snap` every 1800 s and at login (`__HOME__` is filled in by the installer) |
| `install.sh` | Copies the script to `~/.local/bin`, adds the `hw` alias, loads the job |
| `~/Library/Logs/heatwatch/` | Output: `summary.log`, `report-<time>.txt`, `explain-<time>.txt` |

## Install, update, remove

```sh
./install.sh             # install, or update after editing bin/heatwatch
./install.sh uninstall   # stop the job and remove it (logs are kept)
```

The installed copy lives in `~/.local/bin` instead of being run from this folder, because
launchd jobs can't read `~/Desktop` without a macOS privacy prompt. After editing
`bin/heatwatch`, run `./install.sh` again.

Check the job: `launchctl print gui/$(id -u)/com.ujjwal.heatwatch | grep -E 'state|last exit'`
