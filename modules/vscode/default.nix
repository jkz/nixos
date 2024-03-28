{
  flake-inputs,
  pkgs,
  ...
}: let
  inherit (pkgs) buildEnv vscode-extensions vscode-utils writeTextFile;

  vscodeExtensions = with vscode-extensions; [
    vscodevim.vim

    jnoortheen.nix-ide
    kamadorueda.alejandra

    github.copilot
    github.copilot-chat

    ms-python.python
    ms-python.vscode-pylance
    ms-python.black-formatter

    eamodio.gitlens
  ];

  extensionJsonFile = writeTextFile {
    name = "vscode-extensions-json";
    destination = "/share/vscode/extensions/extensions.json";
    text = vscode-utils.toExtensionJson vscodeExtensions;
  };

  combinedExtensionsDrv = buildEnv {
    name = "vscode-extensions";
    paths = vscodeExtensions ++ [extensionJsonFile];
  };
in {
  imports = [
    flake-inputs.nixos-vscode-server.homeModules.default
  ];

  # TODO explain why we need nix-ld

  # Following instructions from https://nixos.wiki/wiki/Visual_Studio_Code
  services.vscode-server.enable = true;

  home.file = {
    ".vscode-server/data/Machine/settings.json".source = ./settings.json;
    ".vscode-server/data/Machine/keybindings.json".source = ./keybindings.json;

    # This is a slightly hacky fix to make a file available that vscode needs to connect remotely
    ".vscode-server/server-env-setup".source = "${flake-inputs.vscode-remote-wsl}/server-env-setup";

    ".vscode-server/extensions" = {
      source = "${combinedExtensionsDrv}/share/vscode/extensions";
      target = ".vscode-server/extensions";
    };
  };
}
