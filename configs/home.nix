{
  username,
  pkgs,
  lib,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  homeDirectory =
    if isDarwin then
      "/Users/${username}"
    else if isLinux then
      "/home/${username}"
    else
      throw "wtf is this system";
in
{
  imports = [
    ./home/.
  ];

  home = {
    stateVersion = "24.11";
    inherit username homeDirectory;

    sessionVariables = {
      PYTHONDONTWRITEBYTECODE = "1";
      PYTHON_HISTORY = "/dev/null";
    };

    file = {
      ".nanorc".text = "include ${pkgs.nanorc}/share/*.nanorc";
      ".bash_sessions_disable".text = "";
    };
  };

  fonts.fontconfig.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    bashrcExtra = "unset HISTFILE";
  };

  # --- Linux (GNOME) Specific Settings ---
  dconf.settings = lib.mkIf isLinux {
    "org/gnome/desktop/peripherals/touchpad" = {
      "natural-scroll" = false;
      "tap-to-click" = true;
    };
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      show-battery-percentage = true;
    };
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };

}
