#!/usr/bin/env bash

# Install script for the “discord.py” feature
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

# Helper: print warning
function warn() {
  echo -e "${YELLOW}${BOLD}Warning:${RESET} $1" >&2
}
# Helper: print logs
function log() {
  echo -e "${BLUE}$1${RESET}" >&2
}

# Ensure pyenv shims are loaded, so pip points into the venv
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
else
  warn "pyenv not found, assuming system pip is correct"
fi

log "Installing discord.py..."
pip install discord.py