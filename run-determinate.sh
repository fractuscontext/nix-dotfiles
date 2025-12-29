#!/bin/bash
trap "echo; exit" INT
set -e

if ! command -v nix &> /dev/null; then
    echo "[!] Nix is not installed."
    echo "[+] Installing via Determinate Systems..."
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install --prefer-upstream-nix
    
    echo "[OK] Nix installed."
    echo "[!] Please close this terminal and open a new one to load Nix into your path."
    echo "    Then, run this script again."
    exit 0
fi