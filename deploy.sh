#!/usr/bin/env bash

# 1. strict mode: exit on error, undefined variables, or pipe failures
set -euo pipefail

# 2. Get the absolute path of the directory where this script resides
#    (works even if you run the script from a different folder)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# --- CONFIGURATION START ---
REMOTE_USER="root"
REMOTE_HOST="fv2.freopen.org"
REMOTE_DIR="/nix/config"
# --- CONFIGURATION END ---

TARGET_ACTION="switch"

for arg in "$@"; do
  if [[ "$arg" == "--boot" ]]; then
    TARGET_ACTION="boot"
    echo ">> Mode selected: BOOT (will apply on next restart)"
  fi
done

echo "Syncing local directory: $SCRIPT_DIR"
echo "To remote: $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

rsync -rltDvz --no-p --no-g --no-o \
    --exclude='flake.lock' \
    --exclude='.git/' \
    --exclude='result' \
    --delete \
    "$SCRIPT_DIR/" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

echo "Sync complete."

ssh -t "$REMOTE_USER@$REMOTE_HOST" "
    set -e
    cd '$REMOTE_DIR'
    
    function cleanup {
        rm -f result
        echo '>> Temporary build link removed.'
    }
    trap cleanup EXIT

    # Build the system but do not activate it yet. 
    # This creates a './result' symlink to the new closure.
    echo 'Building configuration...'
    nixos-rebuild build --flake $REMOTE_DIR #--no-update-lock-file

    echo 'Generating diff...'
    # Diff current system vs the new build
    # We pipe to bat, forcing color and plain style for clean reading
    nix-diff /run/current-system ./result --color always --skip-already-compared --context 3 | bat --style=plain --paging=never
"

# 4. Confirmation Prompt
echo "----------------------------------------------------"
read -p "Do you want to apply this configuration ($TARGET_ACTION)? [y/N] " -n 1 -r
echo    # move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo ">> Deployment aborted by user."
    exit 1
fi

# 5. Remote Apply
echo ">> Applying configuration..."
ssh -t "$REMOTE_USER@$REMOTE_HOST" "nixos-rebuild $TARGET_ACTION --flake $REMOTE_DIR --no-update-lock-file"

echo ">> Deployment successfully finished!"
