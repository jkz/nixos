{ flake-inputs, ... }:
{
  services.vscode-server.enable = true;

  # Following instructions from https://nixos.wiki/wiki/Visual_Studio_Code
  programs.nix-ld.enable = true;

  home-manager.sharedModules = [
    ({ ... }: {
      home.file.".vscode-server/server-env-setup".source = "${flake-inputs.nixos-vscode-server}/server-env-setup";
    })
  ];
}
