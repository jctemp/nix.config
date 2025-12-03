# home/users/zen.nix
{ ... }:
let
  user = import ../users/zen.nix;
in
{
  imports = [
    ./modules/ui.nix
    ./modules/development.nix
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  programs.git.settings = {
    user = {
      name = user.identity;
      email = user.email;
      signingKey = "~/.ssh/id_ed25519_github.pub";
    };
  };
}
