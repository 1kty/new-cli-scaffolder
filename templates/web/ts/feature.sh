#!/usr/bin/env bash

# Install script for the “typescript” feature
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

log "Installing typescript..."
pnpm add --save-dev typescript @types/node eslint-config-airbnb-typescript @typescript-eslint/eslint-plugin @typescript-eslint/parser
pnpm exec tsc --init
