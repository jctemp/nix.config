{ config, ... }:
let
  hasBluetoothDevice = builtins.length (config.facter.report.hardware.bluetooth or [ ]) > 0;
in
{
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = hasBluetoothDevice;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = "true";
        KernelExperimental = "true";
      };
    };
  };
}
