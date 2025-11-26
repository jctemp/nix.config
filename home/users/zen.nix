# home/users/zen.nix
{ ... }:
{
  imports = [
    ../modules/ui.nix
    ../modules/development.nix
  ];

  home = {
    username = "zen";
    homeDirectory = "/home/zen";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  programs.git.settings = {
    user = {
      name = "Jamie Temple";
      email = "jamie.c.temple@gmail.com";
      signingKey = "6A89175BB28B8B81";
    };
    commit.gpgSign = true;
    gpg.format = "openpgp";
  };
}
