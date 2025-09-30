{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.impermanence.nixosModules.impermanence
  ];

  options.host.partition = {
    device = lib.mkOption {
      type = lib.types.str;
    };
    persist.path = lib.mkOption {
      default = "/persist";
      type = lib.types.str;
    };
    boot.size = lib.mkOption {
      default = "1M";
      type = lib.types.str;
    };
    esp.size = lib.mkOption {
      default = "2G";
      type = lib.types.str;
    };
    swap.size = lib.mkOption {
      default = "16G";
      type = lib.types.str;
    };
    root.size = lib.mkOption {
      default = "100%";
      type = lib.types.str;
    };
  };

  config =
    let
      cfg = config.host.partition;

      zfs = rec {
        pool = "rpool";
        root = "local/root";
        path = "${pool}/${root}";
        blank = "${path}@blank";
        rollback = ''
          # During the post device phase the ZFS pools are not yet imported and
          # to avoid any issues with a rollback we have to manually do it. This
          # is not done automatically anymore. Some change in a NixOS version
          # bricked the direct rollback. Also, disko might not export the pools
          # properly. So we need to pre-import the pools without mounting:
          #
          # -N prevents automatic mounting (let the mount phase handle this)
          # -f forces import even if the pool wasn't cleanly exported (unsure)
          # 
          zpool import -N -f ${zfs.pool}
          echo "ZFS[code=$?]: import pool ${zfs.pool}"

          zfs rollback -r ${zfs.blank}
          echo "ZFS[code=$?]: rollback of partition ${zfs.blank}"
        '';
      };

      # ===============================================================
      #       ZFS AUXILLARY
      # ===============================================================
      zpoolOptions = {
        ashift = "12";
        autotrim = "on";
      };

      rootFsOptions = {
        acltype = "posixacl";
        canmount = "off";
        dnodesize = "auto";
        normalization = "formD";
        relatime = "on";
        xattr = "sa";
        compression = "zstd";
      };

      snapshotScript = ''
        set -o errexit
        set -o nounset
        set -o pipefail

        if ! zfs list -t snapshot '${zfs.blank}' > /dev/null 2>&1; then
          echo "Creating blank snapshot: ${zfs.blank}"
          zfs snapshot "${zfs.blank}"
        else
          echo "Blank snapshot already exists: ${zfs.blank}"
        fi
      '';
    in
    {
      services.zfs = {
        autoScrub.enable = true;
        autoSnapshot.enable = false;
        trim.enable = true;
        trim.interval = "weekly";
      };

      environment.persistence."${cfg.persist.path}" = {
        enable = true;
        hideMounts = true;
        directories = [
          "/var/lib/systemd/coredump"
          "/var/lib/nixos"
          "/etc/NetworkManager/system-connections"
        ];
      };

      boot = {
        # ZFS rollback for impermanence (zfs pool not imported after device, so we
        # need to postpone the rollback and ensure mounted 'partitions')
        # TODO: import ZFS pool and then rollback
        initrd.postDeviceCommands = lib.mkAfter zfs.rollback;

        tmp.cleanOnBoot = true;

        supportedFilesystems = [
          "btrfs"
          "reiserfs"
          "vfat"
          "f2fs"
          "xfs"
          "ntfs"
          "cifs"
          "zfs"
        ];

        loader = {
          systemd-boot = {
            enable = true;
            configurationLimit = 5;
          };
          efi.canTouchEfiVariables = true;
        };

        binfmt.emulatedSystems = [
          "x86_64-windows"
          "aarch64-linux"
        ];
      };

      fileSystems."${cfg.persist.path}".neededForBoot = true;
      disko = {
        devices = {
          # ===============================================================
          #       DISK PARTITIONING
          # ===============================================================
          disk.main = {
            imageName = "nixos-disko-root-zfs";
            device = cfg.device;
            # define VM image size - needed for disko vm test
            imageSize = "32G";
            type = "disk";
            content = {
              type = "gpt";
              partitions = {
                # ===============================================================
                #       BIOS BOOT PARTITION
                # ===============================================================
                boot = {
                  label = "BOOT";
                  size = cfg.boot.size;
                  type = "EF02"; # BIOS boot partition
                };

                # ===============================================================
                #       EFI SYSTEM PARTITION
                # ===============================================================
                esp = {
                  label = "EFI";
                  size = cfg.esp.size;
                  type = "EF00"; # EFI system partition
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "umask=0077" ];
                  };
                };

                # ===============================================================
                #       ENCRYPTED SWAP PARTITION
                # ===============================================================
                encryptedSwap = {
                  size = cfg.swap.size;
                  content = {
                    type = "swap";
                    randomEncryption = true;
                    priority = 100;
                  };
                };

                # ===============================================================
                #       ZFS ROOT PARTITION
                # ===============================================================
                root = {
                  size = cfg.root.size;
                  content = {
                    type = "zfs";
                    pool = zfs.pool;
                  };
                };
              };
            };
          };

          # ===============================================================
          #       ZFS POOL CONFIGURATION
          # ===============================================================
          zpool."${zfs.pool}" = {
            type = "zpool";
            mountpoint = "/";
            options = zpoolOptions;
            rootFsOptions = rootFsOptions;
            datasets = {
              # ===============================================================
              #       LOCAL DATASETS (EPHEMERAL)
              # ===============================================================
              "local" = {
                type = "zfs_fs";
                options.mountpoint = "none";
              };

              # Root filesystem - rolled back on boot to blank snapshot
              "${zfs.root}" = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = "/";
                postCreateHook = snapshotScript;
              };

              # Nix store - persistent across reboots
              "local/nix" = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = "/nix";
              };

              # ===============================================================
              #       SAFE DATASETS (PERSISTENT)
              # ===============================================================
              "safe" = {
                type = "zfs_fs";
                options.mountpoint = "none";
              };

              # User home directories
              "safe/home" = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = "/home";
              };

              # System persistence directory
              "safe/persist" = {
                type = "zfs_fs";
                options.mountpoint = "legacy";
                mountpoint = cfg.persist.path;
              };
            };
          };
        };
      };

    };
}
