{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-facter-modules.nixosModules.facter
  ];

  options.host.facter = {
    enable = lib.mkOption {
      default = true;
      type = lib.types.bool;
    };
  };

  config =
    let
      cfg = config.host.facter;
    in
    lib.mkIf cfg.enable {
      facter.reportPath = "${inputs.self}/host/${config.networking.hostName}/hardware.json";
      # TODO: NVIDIA and Bluetooth
    };
}
