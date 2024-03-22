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
      conf = "sudo vim /etc/nixos";
      osre = "sudo nixos-rebuild switch --impure";
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
      amend = "commit --amend --no-edit";
      pfl = "push --force-with-lease";
      tree = "log --graph --oneline --all";
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

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
