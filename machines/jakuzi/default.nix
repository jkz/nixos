{ pkgs, ... }:

{
  networking.hostName = "jakuzi";

  imports = [
    ../common.nix
  ];

  wsl = {
    enable = true;
    defaultUser = "jkz";
    extraBin = with pkgs; [
      # Present the nil binary to vscode
      { src = "${nil}/bin/nil"; }
    ];
  };

  environment.variables = {
    EDITOR = "code";
  };
}
