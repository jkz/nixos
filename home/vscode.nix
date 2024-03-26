{ config, flake-inputs, pkgs, ...}: {
  imports = [
    flake-inputs.nixos-vscode-server.homeModules.default
  ];

  # TODO explain why we need nix-ld
  # Following instructions from https://nixos.wiki/wiki/Visual_Studio_Code
  services.vscode-server.enable = true; 

  programs.vscode = {
    enable = true;
    # extensions = with flake-inputs.nix-vscode-extensions.extensions.${builtins.currentSystem}.vscode-marketplace; [
    # extensionDir = "vscode-server";
    mutableExtensionsDir = false;

    # vscode has UI vs Workspace extensions, that require or prefer to run locally or remotely 
    # respectively. Right now there is no way to force a UI to install a given extension,
    # although we can hint by installing them locally.
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      jnoortheen.nix-ide

      eamodio.gitlens

      ms-python.python
      ms-python.vscode-pylance
      # ms-python.debugpy

      # ms-vscode-remote.remote-wsl
      github.copilot
      github.copilot-chat
    ];
  };

  home.file = {
    # This is a slightly hacky fix to make a file available that vscode needs to connect remotely
    ".vscode-server/server-env-setup".source = "${flake-inputs.vscode-remote-wsl}/server-env-setup";
    ".vscode-server/data/Machine/settings.json".source = ../dotfiles/vscode/settings.json;

    # Ideally we'd update the vscode home manager module to output extensions here directly, but this is a workaround for now.
    ".vscode-server/extensions".source = config.lib.file.mkOutOfStoreSymlink "/home/jkz/.vscode/extensions";
  };

  # extensionsList = with flake-inputs.nix-vscode-extensions.extensions.${builtins.currentSystem}.vscode-marketplace; [
  #   ms-python.python
  # ];
}
