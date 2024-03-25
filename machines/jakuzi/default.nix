{ pkgs, flake-inputs, ... }:

{
  networking.hostName = "jakuzi";

  imports = [
    ../common.nix
    (import ../../home/vscode.nix).nixosModule
  ];

  wsl = {
    enable = true;
    defaultUser = "jkz";
  };

  environment.variables = {
    EDITOR = "code";
  };
}
