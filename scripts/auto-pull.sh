#!/usr/bin/env bash
# Pulls the latest changes for the dragon game.
# Uses --ff-only so a force-push or history rewrite is rejected, not applied.
# Designed to be invoked by launchd on a timer.
set -eu
cd "$(dirname "$0")/.."
exec git pull --ff-only 2>&1
