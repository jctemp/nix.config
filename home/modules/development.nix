# home/modules/development.nix
{ pkgs, ... }:
{
  # TODO: Add more dev tools later

  imports = [ ./cli.nix ];
  home.packages = with pkgs; [
  ];
}
