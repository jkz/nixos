{
  "@darwin" = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      _1password
    ];
  };
  "@nixos" = {...}: {
    programs._1password.enable = true;
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
