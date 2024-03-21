# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, inputs, ... }:
let
  nixos-vscode-server = builtins.fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master";
in
{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
    (import "${nixos-vscode-server}/modules/vscode-server")
  ];

  # This conf is for nixos running on WSL on my windows machine
  wsl = {
    enable = true;
    defaultUser = "jkz";
    extraBin = with pkgs; [
      # These were all necessary to get vscode remote to connect
      { src = "${coreutils}/bin/uname"; }
      { src = "${coreutils}/bin/readlink"; }
      { src = "${coreutils}/bin/sed"; }
      { src = "${coreutils}/bin/cat"; }
    ];
  };

  environment.variables = {
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [
    comma
    nix-index
    wget
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  services.vscode-server.enable = true;

  # solution adapted from: https://github.com/K900/vscode-remote-workaround
  # more information: https://github.com/nix-community/NixOS-WSL/issues/238 and https://github.com/nix-community/NixOS-WSL/issues/294
  systemd.user = {
    paths.vscode-remote-workaround = {
      wantedBy = ["default.target"];
      pathConfig.PathChanged = "%h/.vscode-server/bin";
     };
    services.vscode-remote-workaround.script = ''
      for i in ~/.vscode-server/bin/*; do
        echo "Fixing vscode-server in $i..."
        ln -sf ${pkgs.nodejs_18}/bin/node $i/node
      done
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
