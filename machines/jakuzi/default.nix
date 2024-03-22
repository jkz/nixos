{ pkgs, ... }:
{
  networking.hostName = "jakuzi";

  imports = [
    ../common.nix
    ../../home/vscode.nix
  ];

  # TODO currently struggling to avoid infinite recursion here
  # imports = [
  #   # <nixos-wsl/modules>
  #   # flake-inputs.nixos-wsl.nixosModules.wsl
  # ];

  wsl = {
    enable = true;
    defaultUser = "jkz";
  };

  environment.variables = {
    EDITOR = "code";
  };
}
