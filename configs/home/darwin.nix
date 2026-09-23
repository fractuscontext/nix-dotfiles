{ pkgs, lib, ... }:

{
  targets.darwin.defaults = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      "com.apple.mouse.tapBehavior" = 1;
    };
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.finder" = {
      _FXSortFoldersFirst = true;
      FXPreferredViewStyle = "Nlsv";
      AppleShowAllFiles = true;
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
      ShowPathbar = true;
    };
    "com.apple.controlcenter" = {
      BatteryShowPercentage = true;
    };
  };
}
