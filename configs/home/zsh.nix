{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin isLinux;
  homeDirectory = config.home.homeDirectory;
in
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      # --- Completion & Colors ---
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

      # --- History Config ---
      HISTFILE="$HOME/.zsh_history"
      HISTSIZE=50000
      SAVEHIST=10000
      export LESSHISTFILE=-

      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt INTERACTIVE_COMMENTS
      setopt HIST_IGNORE_SPACE
      setopt HIST_IGNORE_ALL_DUPS
      setopt INC_APPEND_HISTORY
      setopt HIST_VERIFY
      setopt EXTENDED_GLOB

      # --- Smart History Filtering ---
      zshaddhistory() {
        local line="''${1%%$'\n'}"
        local cmd="''${''${(z)line}[1]}"

        if [[ "$line" == *['|<>']* ]]; then
          return 0
        fi

        case "$line" in
          ls|ls\ *|ll|la|exa\ *|eza\ *|tree\ *)               return 1 ;;
          cd|cd\ *|pwd|popd|popd\ *|pushd|pushd\ *|dirs)      return 1 ;;
          clear|exit|history|date|jobs|fg|bg)                 return 1 ;;
          htop|htop\ *)                                       return 1 ;;
          man\ *|which\ *|file\ *|open\ *|codium\ *)          return 1 ;;
          ping\ *|dig\ *|nslookup\ *)                         return 1 ;;
          echo\ *|cat\ *|less\ *|bat\ *)                      return 1 ;;
          source\ .venv*|source\ venv*|conda\ activate\ *)    return 1 ;;
          git\ status|git\ status\ *|git\ add\ *|git\ diff\ *) return 1 ;;
          git\ log\ *|git\ show\ *|git\ branch\ *)            return 1 ;;
          git\ switch\ *|git\ checkout\ *|git\ fetch\ *|git\ pull\ *) return 1 ;;
          git\ push\ *|git\ stash\ *|git\ restore\ *)         return 1 ;;
        esac

        whence "$cmd" > /dev/null || return 1
        return 0
      }

      # --- Powerlevel10k ---
      if [[ $TERM = "xterm-256color" ]]; then
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          [[ -f ${homeDirectory}/.p10k.zsh ]] && source ${homeDirectory}/.p10k.zsh
      fi

      # --- Custom Functions ---
      ns() { 
        local pkg_args=() 
        for x in "$@"; do pkg_args+=("nixpkgs#$x"); done
        nix shell "''${pkg_args[@]}" 
      }

      fix-quarantine() {
        sudo xattr -rd com.apple.quarantine "$@"
      }

      # --- Prettier ls ---
      ls() {
        if [[ $# -eq 0 ]]; then
          ${pkgs.eza}/bin/eza \
            --long \
            --octal-permissions \
            --no-permissions \
            --no-time \
            --no-user \
            --dereference \
            --icons=auto \
            --group-directories-first
        else
          ${pkgs.eza}/bin/eza --group-directories-first "$@"
        fi
      }

      ${lib.optionalString isDarwin ''
        fix-quarantine() { sudo xattr -rd com.apple.quarantine "$@"; }
        rm() { echo "macOS: Use trash (or /bin/rm if you must)."; return 1; }
      ''}

      ${lib.optionalString isLinux ''
        alias rm='rm -I'
      ''}

      # Function to nuke history entries starting with any of the provided arguments
      history_nuke() {
          if [[ $# -eq 0 ]]; then
              echo "Usage: hdel <cmd1> <cmd2> ..."
              return 1
          fi
          fc -W
          local search_terms="''${(j:|:)@}"
          local pattern="^(: [0-9]+:[0-9]+;)?($search_terms)"
          if [[ "$OSTYPE" == "darwin"* ]]; then
              sed -i ''' -E "/$pattern/d" "$HISTFILE"
          else
              sed -i -E "/$pattern/d" "$HISTFILE"
          fi
          fc -R
          echo "Nuked history entries starting with: ''${(j:, :)@}"
      }

      # --- Welcome Banner ---
      ${pkgs.fortune-kind}/bin/fortune-kind | ${pkgs.cowsay}/bin/cowsay -f koala
    '';

    # Merge common aliases with platform-specific ones
    shellAliases = {
      cat = "${pkgs.bat}/bin/bat -pp";
      mkdir = "mkdir -p";
      mv = "mv -i";
      cp = "cp -i";
      gc = "sudo nix-collect-garbage -d";
      fix-ssh-perms = "find ${homeDirectory}/.ssh -type f -exec chmod 600 {} +";
    }
    // lib.optionalAttrs isDarwin {
      # macOS Only Aliases
      fix-launchpad = "sudo find 2>/dev/null /private/var/folders/ -type d -name com.apple.dock.launchpad -exec rm -rf {} +; killall Dock";
      fix-ds_store = "chflags nouchg .DS_Store; rm -rf .DS_Store; pkill Finder; touch .DS_Store; chflags uchg .DS_Store";
    };
  };
}
