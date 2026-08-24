{
  description = "subha279 NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
    };

    claude-desktop = {
      url = "github:aaddrick/claude-desktop-debian";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      apple-fonts,
      claude-desktop,
      ...
    }:
    let
      vars = import ./lib/variables.nix;
    in
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            {
              nixpkgs.overlays = [
                apple-fonts.overlays.default
                claude-desktop.overlays.default
              ];
            }

            stylix.nixosModules.stylix
            ./hosts/laptop

            home-manager.nixosModules.home-manager

            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.${vars.username} = import ./home;
            }
          ];
        };
      };
    };
}
