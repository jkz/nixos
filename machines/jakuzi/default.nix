{ pkgs, flake-inputs, ... }:

{
  networking.hostName = "jakuzi";

  imports = [
    ../common.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "jkz";
  };

  environment.variables = {
    EDITOR = "code";
  };

  home-manager.sharedModules = [
    ../../home
    ../../home/vscode.nix
  ];
}
