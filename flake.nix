{
  description = "jkz's NixOS config";

  inputs = {
    # Using nixpkgs-unstable over nixos-unstable because of an issue with the aws package that hadn't landed in nixos-unstable yet
    # TBD What we want to use in the future
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    alejandra.url = "github:kamadorueda/alejandra/3.0.0";
    alejandra.inputs.nixpkgs.follows = "nixpkgs";

    # VS Code WSl setup
    vscode-remote-wsl.url = "github:sonowz/vscode-remote-wsl-nixos";
    vscode-remote-wsl.flake = false;
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";

    _1password-shell-plugins.url = "github:1Password/shell-plugins";

    # Darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Hraban stuff
    org-llm.url = "github:hraban/org-llm";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-wsl,
    nixos-vscode-server,
    alejandra,
    nix-darwin,
    ...
  } @ inputs: {
    darwinConfigurations = {
      jkz-mbp = nix-darwin.lib.darwinSystem {
        modules = [
          ./machines/jkz-mbp
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              flake-inputs = inputs;
            };
            home-manager.users.jkz = import ./modules/home.nix;
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."jkz-mbp".pkgs;
    };
    nixosConfigurations = {
      jakuzi =
        nixpkgs.lib.nixosSystem
        {
          system = "x86_64-linux";
          specialArgs = {
            flake-inputs = inputs;
          };
          modules = [
            ./machines/jakuzi
            nixos-wsl.nixosModules.wsl
            nixos-vscode-server.nixosModules.default

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                flake-inputs = inputs;
              };
              home-manager.users.jkz = import ./modules/home.nix;
            }

            ({
              nixpkgs,
              lib,
              ...
            }: {
              nixpkgs.config.allowUnfreePredicate = pkg:
                builtins.elem (lib.getName pkg) [
                  "vscode"
                  "vscode-extension-github-copilot"
                  "vscode-extension-github-copilot-chat"
                  "vscode-extension-MS-python-vscode-pylance"
                  "1password"
                  "1password-cli"
                ];
            })
          ];
        };
    };
  };
}
