#!/bin/bash
trap "echo; exit" INT
set -e

pushd "$(dirname "$0")" > /dev/null

nix run --extra-experimental-features "nix-command flakes" ".#homeConfigurations.haruka.activationPackage"

popd > /dev/null

echo "[OK] Done!"
