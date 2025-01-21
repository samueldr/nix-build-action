{ pkgs ? (import (import ./npins).nixpkgs {})
}:

rec {
  a = pkgs.callPackage (
    { runCommand }:
    runCommand "a" {} ''
      echo a > $out
    ''
  ) {};
  b = pkgs.callPackage (
    { runCommand }:
    runCommand "b" {} ''
      echo b > $out
    ''
  ) {};
  c = pkgs.callPackage (
    { runCommand, a, b }:
    runCommand "c" { inherit a b; } ''
      (
      cat $a
      cat $b
      echo c
      )> $out
    ''
  ) { inherit a b; };
}
