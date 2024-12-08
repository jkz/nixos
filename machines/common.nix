{
  "@nixos" = {
    pkgs,
    flake-inputs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      comma
      nix-index
      wget
      flake-inputs.alejandra.defaultPackage.${system}
    ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    # This lets us use precompiled binaries that otherwise have linker issues
    programs.nix-ld.enable = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.11"; # Did you read the comment?
  };
  "@darwin" = {
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      comma
      nix-index
      wget
      # flake-inputs.alejandra.defaultPackage.${system}
    ];

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
