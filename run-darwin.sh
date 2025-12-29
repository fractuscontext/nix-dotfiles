#!/bin/bash
trap "echo; exit" INT
set -e

# Go to the script directory
pushd "$(dirname "$0")" > /dev/null

# DEBUG: Show what the script sees. 
# We use ':-<unset>' to print "<unset>" if the variable is empty.
echo "[*] \$HOST variable set to '${HOST:-<unset>}'"

# Logic:
# 1. Try $HOST (from user env, must be exported)
# 2. Try POSIX
# 3. Fallback to 'apple-seeds'
TARGET="${HOST:-$(uname -n || echo "apple-seeds")}"

# Strip .local from hostname if present (macOS adds this sometimes)
TARGET=${TARGET%.local}

echo "[*] Building configuration for: .#$TARGET"

# Check for darwin-rebuild presence
sudo nix run "nix-darwin#darwin-rebuild" -- switch --flake ".#$TARGET"

popd > /dev/null
echo "[OK] Done!"
