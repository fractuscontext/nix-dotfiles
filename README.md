# ❄️ nix-dotfiles / fractuscontext

Single-user `nix-darwin` + `home-manager` flake

## Structure

```text
.
├── flake.nix           # Flake inputs + darwin configuration
├── run-darwin.sh       # Bootstrap & rebuild
├── run-ansible.sh      # Ansible playbook runner
├── ansible/            # Tasks for runtime-managed files
└── configs/
    ├── darwin.nix      # System-level macOS config
    └── home.nix        # Home Manager entrypoint
        ├── git.nix
        ├── packages.nix
        └── zsh.nix
```

## Usage

```sh
./run-darwin.sh        # install Nix (Determinate) + rebuild system
./run-ansible.sh       # apply Ansible-managed configs
```

Targets `.#apple-seeds` by default. Override with `export HOST=other-machine`.

## What's in it

### System (`darwin.nix`)

- Blocks Apple OCSP telemetry
- Terminal Developer Mode
- Muted startup chime

### Home (`home.nix`)

- **Packages** — LibreWolf, VSCodium, Ungoogled Chromium, Whisky, UTM, etc.
- **Mac App Util** — links GUI apps to `/Applications/Nix Apps`
- **Git** — SSH signing, `main` as default branch
- **macOS defaults** — Finder list view, hidden files, tap-to-click, battery %
- **Zsh** — Powerlevel10k, syntax highlighting, custom aliases

### NUR

Custom macOS app packages via [`fractuscontext/nix-nur`](https://github.com/fractuscontext/nix-nur) (auto-updated DMGs).

## Why Ansible alongside Nix?

Ansible handles files that programs write to at runtime (e.g. `~/.ssh/config`, `~/.kube/config`, `~/.gnupg/`). If only *you* edit it, keep it in Nix.

**License:** MIT, i mean, who cares
