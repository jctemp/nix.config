path:
let
  user = import path;
in
{
  imports = [
    ./modules/wayland.nix
    ./modules/applications.nix
    ./modules/editor.nix
    ./modules/shell.nix
    ./modules/git.nix
    ./modules/gpg.nix
  ];

  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
    stateVersion = "24.11";
    enableNixpkgsReleaseCheck = false;
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
    signing = {
      key = "0x2A76355E27FF9075";
      signByDefault = true;
    };
  };
}
