{ flake-inputs, ... }:
{
  imports = [
    flake-inputs.nixos-vscode-server.homeModules.default
  ];
  # services.vscode-server.enable = true;

  # TODO explain why we need nix-ld
  # Following instructions from https://nixos.wiki/wiki/Visual_Studio_Code

  home.file.".vscode-server/server-env-setup".source = "${flake-inputs.nixos-vscode-server}/server-env-setup";
}
