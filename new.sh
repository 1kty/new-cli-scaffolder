#!/usr/bin/env bash

# "new" CLI Bootstrap Script
# Usage: new <type> [features...]
# Default supported types: python | rust | go | lua | node | web | c | cpp
# Supported web features (if type=web): typescript react vue angular svelte tailwind sass

# Determine script directory reliably
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
PROJECT_ROOT="$HOME/Projects"

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
# Helper: print success
function success() {
  echo -e "${GREEN}$1${RESET}" >&2
}
# Helper: print logs
function log() {
  echo -e "${BLUE}$1${RESET}" >&2
}
# Helper: prompt input
function prompt() {
  read -p "$(echo -e "${CYAN}$1${RESET}")" "$2"
}

# Parse positional args
TYPE="$1"
shift || true
FEATURES=("$@")
if [[ -z "$TYPE" ]]; then
  error "No project type specified. Usage: new <type> [features...]"
fi

# Verify base template exists before any prompts
BASE_TEMPLATE="$TEMPLATES_DIR/$TYPE/base"
if [[ ! -d "$BASE_TEMPLATE" ]]; then
  error "No base template for type '$TYPE' at $BASE_TEMPLATE"
fi

# Prompt for project name
prompt "Project name? " PROJECT_NAME
if [[ -z "$PROJECT_NAME" ]]; then
  error "Project name cannot be empty"
fi

# Prepare destination
DEST="$PROJECT_ROOT/$PROJECT_NAME"
if [[ -d "$DEST" ]]; then
  error "Directory already exists: $DEST"
fi
mkdir -p "$DEST" || error "Failed to create project directory"
cd "$DEST" || exit

# Copy base template for type into DEST
cp -r "$BASE_TEMPLATE/." . || error "Failed to copy base template"

success "Applied base template for '$TYPE'"

# Run post-creation script if available
POST_SCRIPT="$TEMPLATES_DIR/$TYPE/post.sh"

if [[ -f "$POST_SCRIPT" ]]; then
  if [[ ! -x "$POST_SCRIPT" ]]; then
    log "Making post.sh executable..."
    chmod +x "$POST_SCRIPT"
  fi
  log "Running post-creation script for '$TYPE'..."
  "$POST_SCRIPT" "$DEST" "$PROJECT_NAME"
  success "Environment initialized!"
fi

# Apply feature templates (if any)
function apply_feature() {
  local feature=$1
  local feature_dir

  # Resolve correct feature path
  if [[ -d "$TEMPLATES_DIR/$TYPE/$feature" ]]; then
    feature_dir="$TEMPLATES_DIR/$TYPE/$feature"
  else
    warn "No template for feature '$feature'"
    return
  fi

  log "Applying feature '$feature'..."

  # Run feature script if it exists
  local script_path="$feature_dir/feature.sh"
  if [[ -f "$script_path" ]]; then
    if [[ ! -x "$script_path" ]]; then
      log "Making feature script executable for '$feature'..."
      chmod +x "$script_path"
    fi
    log "Running install script for feature '$feature'..."
    "$script_path" "$DEST" "$PROJECT_NAME"
  fi

  # Handle deletions for files and directories starting with '-'
  find "$feature_dir" -depth \( -type f -o -type d \) -name '-*' | while IFS= read -r delete_path; do
    rel_path="${delete_path#$feature_dir/}"

    # Use -- to stop basename/dirname from treating args as options
    base_name="$(basename -- "$rel_path")"
    target_dir="$(dirname -- "$rel_path")"
    target_name="${base_name#-}"

    # Construct target path carefully
    if [ "$target_dir" = "." ]; then
      target="$target_name"
    else
      target="$target_dir/$target_name"
    fi

    log "Removing '$target'..."

    if [ -d "$target" ]; then
      rm -rf -- "$target"
    else
      rm -f -- "$target"
    fi
  done

  # Copy feature files, excluding deletion markers and scripts
  rsync -a --exclude='-*' --exclude='feature.sh' "$feature_dir/" "$DEST/" || error "Failed to apply feature '$feature'"
}

if (( ${#FEATURES[@]} > 0 )); then
  for feat in "${FEATURES[@]}"; do
    apply_feature "$feat"
  done
  success "Features installed!"
fi

# Git initialization
prompt "Initialize Git repo? (y/n) " GIT_CHOICE
if [[ "$GIT_CHOICE" == "y" ]]; then
  git init -b main
  prompt "Create GitHub repo? (y/n) " GH_CHOICE
  if [[ "$GH_CHOICE" == "y" && $(command -v gh) ]]; then
    prompt "Repo name? [${PROJECT_NAME}] " GH_NAME
    GH_NAME=${GH_NAME:-$PROJECT_NAME}
    prompt "Description? " GH_DESC
    prompt "Private? (y/n) " GH_PRIV
    if [[ "$GH_PRIV" == "y" ]]; then
      gh repo create "$GH_NAME" --private --description "$GH_DESC"
    else
      gh repo create "$GH_NAME" --public --description "$GH_DESC"
    fi
    git remote add origin "https://github.com/$(gh api user --jq .login)/$GH_NAME.git"
  fi
fi

success "Project initialized into $DEST !"
