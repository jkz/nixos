{
  "@darwin" = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      _1password-cli
      _1password-gui
    ];
  };
  "@nixos" = {...}: {
    programs._1password-cli.enable = true;
    programs._1password-gui.enable = true;
  };
  "@home" = {
    pkgs,
    flake-inputs,
    ...
  }: {
    imports = [
      flake-inputs._1password-shell-plugins.hmModules.default
    ];

    programs._1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        awscli2
        gh
        openai
      ];
    };

    programs.ssh = {
      enable = true;
      extraConfig = ''
        Host *
            IdentitiesOnly=yes
            IdentityAgent ~/.1password/agent.sock;
      '';
    };
  };
}
