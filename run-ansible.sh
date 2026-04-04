#!/bin/bash
trap "echo; exit" INT
set -e

# Go to the script directory
pushd "$(dirname "$0")" > /dev/null

echo "[*] Running Ansible playbook for mutable state (hosts, ssh, system tweaks)"

# Prefer system ansible-playbook, fall back to uvx
if command -v ansible-playbook &> /dev/null; then
  ANSIBLE_PLAYBOOK=ansible-playbook
  ANSIBLE_GALAXY=ansible-galaxy
elif command -v uvx &> /dev/null; then
  echo "[*] ansible-playbook not found, using uvx fallback"
  ANSIBLE_PLAYBOOK="uvx --from ansible-core ansible-playbook"
  ANSIBLE_GALAXY="uvx --from ansible-core ansible-galaxy"
else
  echo "[!] Neither ansible-playbook nor uvx found. Install Ansible or uv first."
  exit 1
fi

# Install required collections
echo "[*] Installing Ansible collections"
$ANSIBLE_GALAXY collection install community.general --upgrade

$ANSIBLE_PLAYBOOK ansible/site.yml --ask-become-pass

popd > /dev/null
echo "[OK] Done!"
