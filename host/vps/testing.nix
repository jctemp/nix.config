{
  config,
  lib,
  ...
}:
{
  virtualisation.vmVariantWithDisko = {
    virtualisation = {
      fileSystems."${config.host.partition.persist.path}".neededForBoot = true;
      memorySize = 4096;
      cores = 2;
      forwardPorts = [
        {
          from = "host";
          host.port = 8888;
          guest.port = 80;
        }
        {
          from = "host";
          host.port = 2222;
          guest.port = 22;
        }
      ];
    };
    facter.reportPath = lib.mkForce null;
  };
}
