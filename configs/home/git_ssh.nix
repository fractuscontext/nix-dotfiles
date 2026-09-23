{ config, ... }:

let
  homeDirectory = config.home.homeDirectory;
in
{
  programs.ssh = {
    enable = true;

    # Silences the third warning about default values being removed
    enableDefaultConfig = false;

    settings = {
      # Global settings (replaces addKeysToAgent)
      "*" = {
        AddKeysToAgent = "yes";
      };

      # Host-specific settings (replaces matchBlocks)
      "github.com" = {
        IdentityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    ignores = [
      "*.DS_Store"
      "*__pycache__/"
      ".direnv/"
    ];
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    settings = {
      init.defaultBranch = "main";

      user = {
        email = "106440141+fractuscontext@users.noreply.github.com";
        name = "fractuscontext";
        signingkey = "${homeDirectory}/.ssh/id_ed25519.pub";
      };
    };
  };
}
