
# WARN: this file will get overwritten by $ cachix use <name>
{ pkgs, lib, ... }:

let
  folder = ./cachix;
  toImport = name: value: folder + ("/" + name);
  filterCaches = key: value: value == "regular" && lib.hasSuffix ".nix" key;
  imports = lib.mapAttrsToList toImport (lib.filterAttrs filterCaches (builtins.readDir folder));
in {
  inherit imports;
  nix.settings.substituters = ["https://cache.nixos.org/"];
}
