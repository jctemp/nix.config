{ pkgs, ... }:
{
  # ===============================================================
  #       FUSE
  # ===============================================================
  programs.fuse.userAllowOther = true;

  # ===============================================================
  #       SUDO
  # ===============================================================
  security.sudo = {
    extraConfig = "Defaults timestamp_timeout=15";
    wheelNeedsPassword = true;
  };

  # ===============================================================
  #       PACKAGES
  # ===============================================================
  environment.systemPackages =
    let
      pynitrokey-with-pcsc = pkgs.python3Packages.pynitrokey.overridePythonAttrs (old: {
        dependencies = old.dependencies ++ old.optional-dependencies.pcsc;
      });

    in

    with pkgs; [
      gnupg
      pinentry-curses
      age
      sops
    ];
}
