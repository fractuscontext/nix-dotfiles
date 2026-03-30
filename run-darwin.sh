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
TARGET="${HOST:-$(uname -n || echo "CONSUMERISM")}"

# Strip .local from hostname if present (macOS adds this sometimes)
TARGET=${TARGET%.local}

echo "[*] Building configuration for: .#$TARGET"

# Check for darwin-rebuild presence
sudo nix run "nix-darwin#darwin-rebuild" -- switch --flake ".#$TARGET"

echo "Enabling Developer Mode for Terminal..."
spctl developer-mode enable-terminal

echo "Muting Startup Chime"
sudo nvram StartupMute=%01

echo "Disabling extended quarantine attribute for downloaded"
sudo defaults write com.apple.LaunchServices 'LSQuarantine' -bool NO

echo "Configuring Hosts file to block Update and OCSP domains..."
HOSTS_FILE="/etc/hosts"

# List of domains to block
DOMAINS=(
    "swdist.apple.com"
    "swscan.apple.com"
    "swcdn.apple.com"
    "xp.apple.com"
    "gdmf.apple.com"
    "mesu.apple.com"
    "updates.cdn-apple.com"
    "ocsp.apple.com"
    "ocsp2.apple.com"
)

for DOMAIN in "${DOMAINS[@]}"; do
    if ! grep -q "$DOMAIN" "$HOSTS_FILE"; then
    echo "127.0.0.1 $DOMAIN" | sudo tee -a "$HOSTS_FILE" > /dev/null
    echo "Added: $DOMAIN"
    else
    echo "Skipped: $DOMAIN (already exists)"
    fi
done

# Flush DNS cache to apply changes immediately
sudo killall -HUP mDNSResponder
echo "Configuration complete. DNS cache flushed."

echo "Run spctl --master-disable if needed"

popd > /dev/null
echo "[OK] Done!"
