{ pkgs ? (import (import ./npins).nixpkgs {})
}:

pkgs.callPackage (
  { runCommand }:
  runCommand "alt" {} ''
    echo alt-ok > $out
  ''
) {}
