{
  description = "Desktop NixOS Configuration";

  inputs = {
    # NIXOS related inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";

    # USER related inputs
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
            ./host/desktop/default.nix

            inputs.home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.zen = import ./home/users/zen.nix;
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
            ./host/vps/default.nix
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
          program = toString (
            inputs.nixpkgs.legacyPackages.${system}.writeShellScript "home-rebuild" ''
              set -e
        
              HOST=$(hostname)
              USER=$(whoami)
        
              echo "🔨 Building home-manager config for $USER@$HOST..."
        
              ${inputs.nixpkgs.legacyPackages.${system}.nix}/bin/nix build \
                ".#nixosConfigurations.$HOST.config.home-manager.users.$USER.home.activationPackage" \
                --out-link /tmp/home-manager-$USER
        
              echo "✨ Activating..."
              /tmp/home-manager-$USER/activate
        
              echo "✅ Home configuration activated!"
            ''
          );
        };
        fmt = {
          type = "app";
          program = toString (inputs.nixpkgs.legacyPackages.${system}.writeShellScript "fmt" ''
            ${inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt}/bin/nixpkgs-fmt .
          '');
        };
        check = {
          type = "app";
          program = toString (
            inputs.nixpkgs.legacyPackages.${system}.writeShellScript "check" ''
              echo "🔍 Running statix..."
              ${inputs.nixpkgs.legacyPackages.${system}.statix}/bin/statix check . -i .direnv

              echo "🧹 Running deadnix..."
              ${inputs.nixpkgs.legacyPackages.${system}.deadnix}/bin/deadnix . --exclude .direnv

              echo "✅ All checks passed!"
            ''
          );
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
            nixpkgs-fmt # Add this for your formatter
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
