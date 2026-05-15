#!/usr/bin/env bash
# Installs the auto-pull launchd agent so the Mac mini stays in sync with
# the GitHub branch every 60 seconds. Run this once on the Mac mini.
#
#   bash scripts/install-autopull.sh
#
# To remove later:
#   launchctl unload ~/Library/LaunchAgents/com.aria.dragongame.autopull.plist
#   rm        ~/Library/LaunchAgents/com.aria.dragongame.autopull.plist
set -euo pipefail
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO_DIR/scripts/com.aria.dragongame.autopull.plist"
DEST_DIR="$HOME/Library/LaunchAgents"
DEST="$DEST_DIR/com.aria.dragongame.autopull.plist"

mkdir -p "$DEST_DIR"
sed "s|REPO_DIR|$REPO_DIR|g" "$SRC" > "$DEST"
launchctl unload "$DEST" 2>/dev/null || true
launchctl load "$DEST"

echo "Installed auto-pull for: $REPO_DIR"
echo "Checks for updates every 60s."
echo "Tail log:   tail -f /tmp/dragongame-autopull.log"
echo "Uninstall:  launchctl unload $DEST && rm $DEST"
