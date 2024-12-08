{ self, pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  imports = [
    (import ../common.nix)."@darwin"
    (import ../../modules/1password)."@darwin"
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  # nix.settings.experimental-features = "nix-command flakes";
  #ALREADY DEFINED ELSEWHERE

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;
  system.configurationRevision = null;
  #NO REFERENCE TO SELF

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

  users = {
    users = {
      jkz = {
        name = "jkz";
        home = "/Users/jkz";
        # shell = pkgs.zsh;
        shell = pkgs.bash;
        uid = 501;
      };
    };
    knownUsers = [ "jkz" ];
  };
}