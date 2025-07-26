#!/usr/bin/env bash

# Go post‑creation hook
# Arguments:
#   $1 = project directory
#   $2 = project name

# Change into project dir
DEST="$1"
PROJECT_NAME="$2"
cd "$DEST" || exit 1

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
BOLD="\033[1m"
RESET="\033[0m"

# Helper: print logs
function log() {
  echo -e "${BLUE}$1${RESET}" >&2
}

log "Creating project with go mod..."
go mod init github.com/$(gh api user --jq .login)/$PROJECT_NAME