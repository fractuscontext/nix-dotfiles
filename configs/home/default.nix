{ lib, ... }:
let
  inherit (builtins) filter;
  inherit (lib.filesystem) listFilesRecursive;
  inherit (lib.strings) hasSuffix;
in
{
  imports = filter (hasSuffix ".nix") (
    map toString (filter (p: p != ./default.nix) (listFilesRecursive ./.))
  );
}
