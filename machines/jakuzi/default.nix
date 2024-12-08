{pkgs, ...}: {
  networking.hostName = "jakuzi";

  imports = [
    (import ../common.nix)."@nixos"
    (import ../../modules/1password)."@nixos"
    (import ../../modules/example)."@nixos"
  ];

  wsl = {
    enable = true;
    defaultUser = "jkz";
    extraBin = with pkgs; [
      # Present the nil binary to vscode
      {src = "${nil}/bin/nil";}
    ];
  };

  environment.variables = {
    EDITOR = "code";
  };
}
