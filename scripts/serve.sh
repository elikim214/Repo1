#!/usr/bin/env bash
# Serves the dragon game locally on http://localhost:8080
# Pair with `cloudflared tunnel run dragongame` to expose it at
# dragongame.givefreely.org (see setup steps in the chat / repo).
set -euo pipefail
cd "$(dirname "$0")/.."
PORT="${PORT:-8080}"
echo "Serving Save the Princess on http://localhost:${PORT}"
echo "Press Ctrl-C to stop."
exec python3 -m http.server "${PORT}"
