{
  pkgs,
  username,
  hostname,
  ...
}:
{
  networking = {
    hostName = hostname;
    localHostName = hostname;
    computerName = hostname;
  };

  # Define user
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Configure zsh as an interactive shell.
  programs.zsh.enable = true;

  # Enable flakes and optimise store during every build
  nix.settings.experimental-features = "nix-command flakes";

  system.stateVersion = 5;

  # Auto upgrade nix package and the daemon service.
  nix = {
    enable = false;
    package = pkgs.nix;
  };
}
