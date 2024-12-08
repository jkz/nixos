{pkgs, ...}: {
  imports = [
    ./vscode
    (import ./1password)."@home"
    (import ./emacs)."@home"
    (import ./example)."@home"
    (import ./git)."@home"
  ];

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
      lg = "lazygit";
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
