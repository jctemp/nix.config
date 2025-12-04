{ config, lib, ... }:
let
  hasNvidiaDevice = builtins.any (gpu: (gpu.vendor.hex or "") == "10de") (
    config.facter.report.hardware.graphics_card or [ ]
  );
in
{
  services.xserver.videoDrivers = lib.optional hasNvidiaDevice "nvidia";

  hardware.nvidia = lib.mkIf hasNvidiaDevice {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
  };

  hardware.nvidia-container-toolkit.enable = hasNvidiaDevice && config.virtualisation.docker.enable;
  hardware.nvidia-container-toolkit.mount-nvidia-executables = true;
}
