_:
{
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "docker";
    docker = {
      enable = true;
      rootless.enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };
}
