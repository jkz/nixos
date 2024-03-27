{
  description = "jkz's NixOS config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    vscode-remote-wsl.url = "github:sonowz/vscode-remote-wsl-nixos";
    vscode-remote-wsl.flake = false;

    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { nixpkgs, home-manager, nixos-wsl, nixos-vscode-server, ... } @ inputs:
  let
    jkz-lib = import ./lib;
  in
  {
    nixosConfigurations = {
      jakuzi = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = jkz-lib.import-modules "@nixos" [
          ({nixpkgs, lib, ...}: {
            nixpkgs.config.allowUnfreePredicate = pkg:
              builtins.elem (lib.getName pkg) [
                "vscode"
                "vscode-extension-github-copilot"
                "vscode-extension-github-copilot-chat"
                "vscode-extension-MS-python-vscode-pylance"
              ];
          })

          ./machines/jakuzi
          ./home/vscode.nix
          nixos-wsl.nixosModules.wsl
          nixos-vscode-server.nixosModules.default
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit jkz-lib;
              flake-inputs = inputs;
            };
            home-manager.users.jkz = import ./home;
          }
        ];
      };
    };
  };
}
