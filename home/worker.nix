_:
let
  user = import ../users/worker.nix;
in
{
  imports = [
    ./modules/editor.nix
    ./modules/git.nix
    ./modules/gpg.nix
    ./modules/shell.nix
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = "25.11";
  };

  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;
  programs.git = {
    settings = {
      user = {
        name = user.identity;
        inherit (user) email;
      };
    };
  };
}
