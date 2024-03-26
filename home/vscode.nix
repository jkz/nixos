{ flake-inputs, nixpkgs, ...}: {
    imports = [
      flake-inputs.nixos-vscode-server.homeModules.default
    ];

    # TODO explain why we need nix-ld
    # Following instructions from https://nixos.wiki/wiki/Visual_Studio_Code
    services.vscode-server.enable = true; 

    home.file = {
      # This is a slightly hacky fix to make a file available that vscode needs to connect remotely
      ".vscode-server/server-env-setup".source = "${flake-inputs.vscode-remote-wsl}/server-env-setup";

      ".vscode-server/data/Machine/settings.json".source = ../dotfiles/vscode/settings.json;
    };
}
