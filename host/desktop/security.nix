{ pkgs, ... }:
{
  # TODO: Rework the security model of the hosts leverging SecOPS
  services.pcscd.enable = true;

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
  #       LOCKING
  # ===============================================================
  security.pam.services.swaylock = {
    enable = true;
    text = ''
      auth include login
    '';
  };

  # ===============================================================
  #       SECURITY PACKAGES
  # ===============================================================
  environment.systemPackages = with pkgs; [
    swaylock-effects
    gnupg
    libfido2
  ];
}
