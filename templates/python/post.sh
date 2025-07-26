#!/usr/bin/env bash

# Python post‑creation hook
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

# Helper: print error
function error() {
  echo -e "${RED}${BOLD}Error:${RESET} $1" >&2
  exit 1
}
# Helper: print warning
function warn() {
  echo -e "${YELLOW}${BOLD}Warning:${RESET} $1" >&2
}
# Helper: print logs
function log() {
  echo -e "${BLUE}$1${RESET}" >&2
}
# Helper: prompt input
function prompt() {
  read -p "$(echo -e "${CYAN}$1${RESET}")" "$2"
}

# Ask for Python version (or use default)
prompt "Python version (blank = pyenv default)? " PY_VER

# Determine which version to use
if [[ -z "$PY_VER" ]]; then
  # Use current pyenv default
  PY_CHOSEN=$(pyenv version-name)
  warn "Using pyenv default: $PY_CHOSEN"
else
  PY_CHOSEN="$PY_VER"
  # Check if installed
  if ! pyenv versions --bare | grep -qx "$PY_CHOSEN"; then
    warn "Version $PY_CHOSEN not installed."
    # See if it’s available to install
    if pyenv install --list | sed 's/^ *//' | grep -qx "$PY_CHOSEN"; then
      prompt "Install pyenv $PY_CHOSEN? (y/n) " yn
      if [[ "$yn" == "y" ]]; then
        pyenv install "$PY_CHOSEN"
      else
        error "requested Python version not available."
        exit 1
      fi
    else
      error "$PY_CHOSEN not found in pyenv install list."
      exit 1
    fi
  fi
fi

# Create & activate virtualenv named <project>-env
ENV_NAME="${PROJECT_NAME}-env"
log "Creating virtualenv $ENV_NAME for Python $PY_CHOSEN..."
pyenv virtualenv "$PY_CHOSEN" "$ENV_NAME" || {
  error "Failed to create virtualenv. It may already exist."
}

# Set this env as local version
pyenv local "$PROJECT_NAME-env"

# Ensure pip, wheel are up-to-date, then install tools
log "Installing wheel, flake8, black..."
pip install --upgrade pip wheel
pip install flake8 black