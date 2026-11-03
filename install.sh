#!/bin/bash
# Install (or update) heatwatch from this repo, then reload the 30-minute launchd job.
#   ./install.sh            install / update
#   ./install.sh uninstall  stop the job and remove the installed files (logs are kept)
#
# The script is copied to ~/.local/bin rather than run from here: launchd jobs can't
# read ~/Desktop without a macOS privacy prompt, so a symlink into this folder would fail.
set -e
cd "$(dirname "$0")"
LABEL=com.ujjwal.heatwatch
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
BIN="$HOME/.local/bin"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true

if [ "$1" = uninstall ]; then
    rm -f "$PLIST" "$BIN/heatwatch" "$BIN/hw"
    echo "heatwatch removed (logs kept in ~/Library/Logs/heatwatch)"
    exit
fi

mkdir -p "$BIN" "$HOME/Library/Logs/heatwatch"
install -m 755 bin/heatwatch "$BIN/heatwatch"
ln -sf heatwatch "$BIN/hw"
sed "s#__HOME__#$HOME#g" "launchd/$LABEL.plist" > "$PLIST"
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "heatwatch installed: $BIN/heatwatch (alias hw), job $LABEL every 30 min"
