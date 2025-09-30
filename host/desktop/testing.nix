{
  config,
  lib,
  ...
}:
{
  virtualisation.vmVariantWithDisko = {
    virtualisation = {
      fileSystems."${config.host.partition.persist.path}".neededForBoot = true;
      memorySize = 8192;
      cores = 4;
      forwardPorts = [
        {
          from = "host";
          host.port = 8888;
          guest.port = 80;
        }
      ];
    };
    facter.reportPath = lib.mkForce null;
  };
}
