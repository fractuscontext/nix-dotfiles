{ pkgs, lib, ... }:

{

  dconf.settings = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
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
