{
  description = "Desktop NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blender-bin.url = "github:edolstra/nix-warez?dir=blender";
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        desktop = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            {
              host.settings = {
                name = "desktop";
                stateVersion = "24.11";
                timeZone = "Europe/Berlin";
                defaultLocale = "en_US.UTF-8";
                extraLocale = "de_DE.UTF-8";
                keyboardLayout = "us";
              };

              host.users.primary = "zen";

              host.partition = {
                device = "/dev/nvme0n1";
                persist.path = "/persist";
              };
            }
            ./hosts/desktop/default.nix

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.zen = import ./home/zen.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          ];
        };
        vps = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
          };
          modules = [
            {
              host.settings = {
                name = "vps";
                stateVersion = "25.05";
                timeZone = "Europe/Berlin";
                defaultLocale = "en_US.UTF-8";
              };

              host.users.primary = "worker";

              host.partition = {
                device = "/dev/sda";
                persist.path = "/persist";
              };
            }
            ./hosts/vps/default.nix
            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.worker = {
                imports = [ ./home/modules/cli.nix ];
                home.username = "worker";
                home.homeDirectory = "/home/worker";
                home.stateVersion = "25.05";
                programs.home-manager.enable = true;
              };
            }
          ];
        };
      };

      apps.${system} = {
        home-rebuild = {
          type = "app";
          program = "${./scripts/home-rebuild}";
          meta = {
            description = "Rebuild home-manager configuration quickly";
            mainProgram = "home-rebuild";
          };
        };
        fmt = {
          type = "app";
          program = "${./scripts/fmt}";
          meta = {
            description = "Format all Nix files with nixpkgs-fmt";
            mainProgram = "fmt";
          };
        };
        check = {
          type = "app";
          program = "${./scripts/check}";
          meta = {
            description = "Run statix and deadnix linters";
            mainProgram = "check";
          };
        };
      };

      formatter.${system} = inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt;

      devShells.${system}.default =
        let
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        pkgs.mkShellNoCC {
          name = "nix-config";
          packages = with pkgs; [
            bash-language-server
            deadnix
            home-manager
            manix
            nixd
            nix-diff
            nixfmt-rfc-style
            nixpkgs-fmt
            nix-melt
            nix-tree
            statix
            taplo
          ];

          shellHook = ''
            echo "🚀 NixOS Configuration Development Environment"
            echo ""
            echo "Available commands:"
            echo "  sudo nixos-rebuild switch --flake .#desktop  - Full system rebuild"
            echo "  nix run .#home-rebuild                       - Fast home rebuild"
            echo "  nix run .#fmt                                - Format all files"
            echo "  nix run .#check                              - Run all checks"
            echo ""
          '';
        };
    };
}
