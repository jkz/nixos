{
  "@nixos" = ({ pkgs, config, ... } : 
    # We build vscode extensions, but not vscode itself, as we'll be using it remotely from windows through wsl
    # That means there is a manual step of installing extensions locally on windows,
    # but the server-installed versions should hint at what to install.
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
        # script = ''
        #   ln -sfT ${combinedExtensionsDrv}/share/vscode/extensions ${config.services.vscode-server.installPath}/extensions
        # '';
        wantedBy = [ "default.target" ];
      };
    }
  );
  "@home" = ({ config, flake-inputs, pkgs, ...}:
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
    imports = [
      flake-inputs.nixos-vscode-server.homeModules.default
    ];

    # TODO explain why we need nix-ld

    # Following instructions from https://nixos.wiki/wiki/Visual_Studio_Code
    services.vscode-server.enable = true; 

    home.file = {
      ".vscode-server/data/Machine/settings.json".source = ./settings.json;

      # This is a slightly hacky fix to make a file available that vscode needs to connect remotely
      ".vscode-server/server-env-setup".source = "${flake-inputs.vscode-remote-wsl}/server-env-setup";

      # Ideally we'd update the vscode home manager module to output extensions here directly, but this is a workaround for now.
      ".vscode-server/extensions".source = {
        recursive = true;
        source = combinedExtensionsDrv
      }
      # ".vscode-server/extensions".source = config.lib.file.mkOutOfStoreSymlink "/home/jkz/.vscode/extensions";
    };
  });
}