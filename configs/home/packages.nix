{
  pkgs,
  lib,
  pkgs-stable-linux ? null,
  pkgs-stable-darwin ? null,
  pkgs-haruka-darwin ? null,
  ...
}:

let
  inherit (pkgs.stdenv) isDarwin;
  pkgs-stable = if isDarwin then pkgs-stable-darwin else pkgs-stable-linux;

  fonts = with pkgs; [
    # Normal CLI apps & Fonts (Unstable)
    noto-fonts
    source-han-sans
    source-han-mono
    source-han-serif
    source-han-code-jp
    meslo-lgs-nf
  ];

  unstablePackages = with pkgs; [
    fortune-kind
    cowsay
    eza
    bat
    python315FreeThreading
    uv
    htop
    wget
    unar
    asciinema
    asciinema-agg
    nixd
    nixfmt
    ansible
    ansible-lint
  ];

  stablePackages = with pkgs-stable; [
    # Heavy CLI apps (Stable)
    ffmpeg
    imagemagick
    podman
    podman-compose
  ];

  darwinGuiStable = with pkgs-stable; [
    # Heavy GUI apps (Stable)
    audacity
    libreoffice-bin
    vscodium
    remmina
    wireshark
    iina
    utm
  ];

  darwinGuiUnstable = with pkgs; [
    # GUI apps that need unstable for binary cache
    qbittorrent
  ];

  darwinGuiHaruka = with pkgs-haruka-darwin; [
    # Overlay GUI apps
    librewolf
    ungoogled-chromium
    telegram-desktop
    lunarfyi
    kap-bin
  ];

in
{
  home.packages =
    unstablePackages
    ++ fonts
    ++ stablePackages
    ++ lib.optionals isDarwin (darwinGuiStable ++ darwinGuiUnstable ++ darwinGuiHaruka);
}
