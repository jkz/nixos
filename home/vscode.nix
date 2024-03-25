{ flake-inputs, ...}: {
    imports = [
      flake-inputs.nixos-vscode-server.homeModules.default
    ];

    # TODO explain why we need nix-ld
    # Following instructions from https://nixos.wiki/wiki/Visual_Studio_Code
    services.vscode-server.enable = true; 

    home.file.".vscode-server/server-env-setup".source = "${flake-inputs.vscode-remote-wsl}/server-env-setup";
}
