{ config, pkgs, ... }: {
  home.stateVersion = "23.11";
  home.packages = with pkgs; [
    zip
    unzip

    jq
    fzf

    which
    tree
  ];

  programs.home-manager.enable = true;

  programs.vim = {
    enable = true;
    settings = {
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      conf = "sudo vim /etc/nixos/configuration.nix";
      osre = "sudo nixos-rebuild switch --flake $(readlink -f /etc/nixos)#jkz --impure";
    };
  };

  programs.git = {
    enable = true;
    userName = "jkz";
    userEmail = "j.k.zwaan@gmail.com";
    extraConfig = {
      push = { autoSetupRemote = true; };
    };
    aliases = {
      pfl = "push --force-with-lease";
      amend = "commit --amend --no-edit";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
