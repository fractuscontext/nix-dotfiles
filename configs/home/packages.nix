{
  pkgs,
  lib,
  pkgs-stable ? null,
  pkgs-stable-overlay-darwin ? null,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;

  fonts = with pkgs; [
    source-han-serif
    source-han-code-jp
    meslo-lgs-nf
  ];

  unstablePackages =
    with pkgs;
    [
      podman
      podman-compose
      fortune-kind
      cowsay
      eza
      bat
      uv
      htop
      asciinema
      asciinema-agg
      nixd
      nixfmt
      git-filter-repo
      ansible
      ansible-lint
      reuse
    ]
    ++ lib.optionals isLinux [
      # Nothing to add.
    ]
    ++ lib.optionals isDarwin [
      qbittorrent
      utm
      iina
      libreoffice-bin
    ];

  stablePackages =
    with pkgs-stable;
    [
      # Heavy CLI apps (Stable)
      ffmpeg
      imagemagick
      unar
    ]
    ++ lib.optionals isDarwin (
      with pkgs-stable-overlay-darwin;
      [
        # Heavy GUI apps (Stable)
        remmina
        wireshark

        # Overlays
        librewolf
        ungoogled-chromium
        telegram-desktop
      ]
    );

in
{
  home.packages = unstablePackages ++ fonts ++ stablePackages;
}
