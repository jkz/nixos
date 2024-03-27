{
  "@nixos" = ({ pkgs, config, ... } : 
    let
      inherit (pkgs) buildEnv vscode-extensions vscode-utils writeTextFile;

      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix
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

      extensionJsonFile = writeTextFile {
        name = "vscode-extensions-json";
        destination = "/share/vscode/extensions/extensions.json";
        text = vscode-utils.toExtensionJson vscodeExtensions;
      };

      combinedExtensionsDrv = buildEnv {
        name = "vscode-extensions";
        paths = vscodeExtensions ++ [ extensionJsonFile ];
      };
    in {
      systemd.user.services.vscode-server-extensions = {
        description = "VS Code extensions to make available for VS Code server";
        serviceConfig.Type = "oneshot";
        script = ''
          ln -sfT ${combinedExtensionsDrv}/share/vscode/extensions ${config.services.vscode-server.installPath}/extensions
        '';
        wantedBy = [ "default.target" ];
      };
    }
  );
  "@home" = ({ config, flake-inputs, pkgs, ...}: {
    imports = [
      flake-inputs.nixos-vscode-server.homeModules.default
    ];

    # TODO explain why we need nix-ld
    # Following instructions from https://nixos.wiki/wiki/Visual_Studio_Code
    services.vscode-server.enable = true; 

    programs.vscode = {
      enable = false;
      # extensions = with flake-inputs.nix-vscode-extensions.extensions.${builtins.currentSystem}.vscode-marketplace; [
      # extensionDir = "vscode-server";
      mutableExtensionsDir = false;

      # vscode has UI vs Workspace extensions, that require or prefer to run locally or remotely 
      # respectively. Right now there is no way to force a UI to install a given extension,
      # although we can hint by installing them locally.
      # extensions = with pkgs.vscode-extensions; [
      #   vscodevim.vim
      #   jnoortheen.nix-ide

      #   eamodio.gitlens

      #   ms-python.python
      #   ms-python.vscode-pylance
      #   # ms-python.debugpy

      #   # ms-vscode-remote.remote-wsl
      #   github.copilot
      #   github.copilot-chat
      # ];
    };

    home.file = {
      # This is a slightly hacky fix to make a file available that vscode needs to connect remotely
      ".vscode-server/server-env-setup".source = "${flake-inputs.vscode-remote-wsl}/server-env-setup";
      ".vscode-server/data/Machine/settings.json".source = ./settings.json;

      # Ideally we'd update the vscode home manager module to output extensions here directly, but this is a workaround for now.
      ".vscode-server/extensions".source = config.lib.file.mkOutOfStoreSymlink "/home/jkz/.vscode/extensions";
    };

    # extensionsList = with flake-inputs.nix-vscode-extensions.extensions.${builtins.currentSystem}.vscode-marketplace; [
    #   ms-python.python
    # ];
  });
}