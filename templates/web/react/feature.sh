#!/usr/bin/env bash

# Install script for the “react” feature
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/.."

# Remove base web
rm -rf -- * .[!.]* ..?*  

log Scaffolding use vite...
pnpm create vite@latest . --template react-ts -- --yes

# Re-adds prettier and config
pnpm add -D prettier eslint-plugin-prettier eslint-config-prettier

cp "$TEMPLATES_DIR/base/.prettierrc.json" "$DEST/"