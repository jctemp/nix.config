{ config, ... }:
let
  # Import user identity from new location
  user = import ../../users/zen.nix;

  checkGroups = groups:
    builtins.filter (g: builtins.hasAttr g config.users.groups) groups;
in
{
  # Ensure home directory exists
  systemd.tmpfiles.rules = [
    "d /home/${user.name} 0755 ${user.name} users -"
    "d /home/${user.name}/.ssh 0750 ${user.name} users -"
    "d /home/${user.name}/.ssh/sockets 0750 ${user.name} users -"
  ];

  # Create user account
  users.users.${user.name} = {
    isNormalUser = true;
    description = user.identity;
    hashedPassword = user.hashedPassword;
    openssh.authorizedKeys.keys = user.authorizedKeys;
    extraGroups = [ "wheel" ] ++ checkGroups [
      "audio"
      "video"
      "docker"
      "libvirtd"
      "networkmanager"
      "scanner"
      "lp"
      "kvm"
    ];
  };
}
