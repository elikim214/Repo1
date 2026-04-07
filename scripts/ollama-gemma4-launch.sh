#!/usr/bin/env bash
set -euo pipefail

# Launch script for Ollama with Gemma 4 27B model
# Usage: ./scripts/ollama-gemma4-launch.sh [--serve-only] [--pull-only]

MODEL="gemma3:27b"
OLLAMA_HOST="${OLLAMA_HOST:-127.0.0.1:11434}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo -e "${GREEN}[ollama]${NC} $*"; }
warn()  { echo -e "${YELLOW}[ollama]${NC} $*"; }
error() { echo -e "${RED}[ollama]${NC} $*" >&2; }

check_ollama() {
    if ! command -v ollama &>/dev/null; then
        error "Ollama is not installed."
        echo "Install with: curl -fsSL https://ollama.com/install.sh | sh"
        exit 1
    fi
    log "Ollama found: $(ollama --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' || echo 'unknown')"
}

start_server() {
    if curl -sf "http://${OLLAMA_HOST}/api/tags" &>/dev/null; then
        log "Ollama server already running at ${OLLAMA_HOST}"
        return 0
    fi

    log "Starting Ollama server..."
    ollama serve &>/tmp/ollama-serve.log &
    OLLAMA_PID=$!

    for i in $(seq 1 15); do
        if curl -sf "http://${OLLAMA_HOST}/api/tags" &>/dev/null; then
            log "Server started (PID: ${OLLAMA_PID})"
            return 0
        fi
        sleep 1
    done

    error "Server failed to start. Check /tmp/ollama-serve.log"
    exit 1
}

pull_model() {
    if ollama list 2>/dev/null | grep -q "${MODEL}"; then
        log "Model ${MODEL} already available"
        return 0
    fi

    log "Pulling ${MODEL} (this may take a while)..."
    if ! ollama pull "${MODEL}"; then
        error "Failed to pull ${MODEL}"
        error "Check your network connection and ensure registry.ollama.ai is accessible"
        exit 1
    fi
    log "Model ${MODEL} pulled successfully"
}

run_model() {
    log "Launching ${MODEL}..."
    log "Type /bye to exit the chat session"
    echo ""
    ollama run "${MODEL}"
}

show_info() {
    echo ""
    log "Model:    ${MODEL}"
    log "API:      http://${OLLAMA_HOST}"
    log "Chat:     ollama run ${MODEL}"
    log "API call: curl http://${OLLAMA_HOST}/api/generate -d '{\"model\":\"${MODEL}\",\"prompt\":\"Hello\"}'"
    echo ""
}

# Parse arguments
SERVE_ONLY=false
PULL_ONLY=false

for arg in "$@"; do
    case "$arg" in
        --serve-only) SERVE_ONLY=true ;;
        --pull-only)  PULL_ONLY=true ;;
        --help|-h)
            echo "Usage: $0 [--serve-only] [--pull-only]"
            echo ""
            echo "  --serve-only  Start server and pull model, but don't open chat"
            echo "  --pull-only   Only pull the model (assumes server is running)"
            echo ""
            exit 0
            ;;
    esac
done

# Main
check_ollama

if [ "$PULL_ONLY" = true ]; then
    pull_model
    exit 0
fi

start_server
pull_model
show_info

if [ "$SERVE_ONLY" = true ]; then
    log "Server running. Use 'ollama run ${MODEL}' to start chatting."
    exit 0
fi

run_model
