{ config
, pkgs
, lib
, ...
}:
let
  hostName = config.host.settings.name;
  inherit (config.host.settings) stateVersion;
  inherit (config.host.settings) timeZone;
  inherit (config.host.settings) defaultLocale;
in
{
  # ===============================================================
  #       MODULE IMPORTS
  # ===============================================================
  imports = [
    ./hardware.nix
    ./boot.nix
    ./storage.nix
    ./services.nix
    ./security.nix
    ./users.nix

    ../modules/networking.nix
    ../modules/docker.nix
    ../modules/testing.nix
  ];

  # ===============================================================
  #       HOST OPTIONS
  # ===============================================================
  options.host = {
    settings = {
      name = lib.mkOption { type = lib.types.str; };
      stateVersion = lib.mkOption { type = lib.types.str; };
      timeZone = lib.mkOption { type = lib.types.str; };
      defaultLocale = lib.mkOption { type = lib.types.str; };
    };
    users = {
      primary = lib.mkOption { type = lib.types.str; };
      collection = lib.mkOption {
        default = [ ];
        type = lib.types.listOf lib.types.str;
      };
      admins = lib.mkOption {
        default = [ ];
        type = lib.types.listOf lib.types.str;
      };
    };
    partition = {
      device = lib.mkOption { type = lib.types.str; };
      persist.path = lib.mkOption {
        default = "/persist";
        type = lib.types.str;
      };
      boot.size = lib.mkOption {
        default = "1M";
        type = lib.types.str;
      };
      esp.size = lib.mkOption {
        default = "512M";
        type = lib.types.str;
      };
      swap.size = lib.mkOption {
        default = "4G";
        type = lib.types.str;
      };
      root.size = lib.mkOption {
        default = "100%";
        type = lib.types.str;
      };
    };
  };

  # ===============================================================
  #       SYSTEM BASICS
  # ===============================================================
  config = {
    system.stateVersion = stateVersion;
    networking.hostName = hostName;
    networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" hostName);

    # ===============================================================
    #       NIX CONFIGURATION
    # ===============================================================
    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        auto-optimise-store = true;
        keep-outputs = true;
        trusted-users = [ "@wheel" ];
        connect-timeout = 5;
        log-lines = 25;
        min-free = 128000000;
        max-free = 1000000000;
      };
    };

    nixpkgs.config.allowUnfree = true;

    # ===============================================================
    #       LOCALE AND TIME
    # ===============================================================
    time.timeZone = timeZone;
    services.timesyncd.enable = lib.mkDefault true;

    i18n.defaultLocale = defaultLocale;
    console.keyMap = "us";

    # ===============================================================
    #       DOCUMENTATION
    # ===============================================================
    documentation = {
      enable = true;
      dev.enable = false;
      doc.enable = false;
      info.enable = false;
      man.enable = true;
      nixos.enable = true;
    };

    # ===============================================================
    #       SHELL CONFIGURATION
    # ===============================================================
    users.defaultUserShell = pkgs.bash;

    programs.bash = {
      completion.enable = true;
      shellAliases = {
        ls = "ls --color=auto";
        grep = "grep --color=auto";
        df = "df -h";
        du = "du -h";
        free = "free -h";
        ".." = "cd ..";
        system-rebuild = "sudo nixos-rebuild switch --flake .#vps";
      };
    };

    # ===============================================================
    #       GIT SYSTEM CONFIG
    # ===============================================================
    programs.git = {
      enable = true;
      lfs.enable = true;
      config = {
        color.ui = true;
        init.defaultBranch = "main";
        core.editor = "${pkgs.vim}/bin/vim";
      };
    };

    # ===============================================================
    #       ESSENTIAL SYSTEM PACKAGES
    # ===============================================================
    environment.systemPackages = with pkgs; [
      # Core utilities
      curl
      wget
      vim
      tree
      unzip
      zip
      jq
      htop
      tmux

      # Network tools
      dnsutils
      inetutils
      mtr
      tcpdump

      # Development tools
      git
      rsync
    ];
  };
}
