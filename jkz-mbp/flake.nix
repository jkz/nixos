{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    org-llm.url = "github:hraban/org-llm";
    _1password-shell-plugins.url = "github:1Password/shell-plugins";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, ... }:
  let
    configuration = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      # For silicon
      nixpkgs.hostPlatform = "aarch64-darwin";
      # For intel
      # nixpkgs.hostPlatform = "x86_64-darwin";
      system.defaults = {
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      imports = [ inputs._1password-shell-plugins.hmModules.default ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { flake-inputs = inputs; };
        sharedModules = [
          ({ pkgs, lib, config, flake-inputs, ...}: {
            programs = {
              _1password-shell-plugins = {
                # enable 1Password shell plugins for bash, zsh, and fish shell
                enable = true;
                # the specified packages as well as 1Password CLI will be
                # automatically installed and configured to use shell plugins
                plugins = with pkgs; [ gh awscli2 ];
              };

              emacs = {
                enable = true;
                extraPackages = e: let
                  callPackage = pkgs.lib.callPackageWith (pkgs // e);
                in with e; [
                  (callPackage flake-inputs.org-llm.emacsPackages.default {})
                ];
              };
            };
            home.stateVersion = "24.05";
            home.packages = with pkgs; [
              _1password
            ];
          })
        ];
        users.jkz = { imports = [ ]; };
      };

      users = {
        users = {
          jkz = {
            name = "jkz";
            home = "/Users/jkz";
            shell = pkgs.zsh;
            uid = 501;
          };
        };
        knownUsers = [ "jkz" ];
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."jkz-mbp" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."jkz-mbp".pkgs;
  };
}
