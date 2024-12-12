{
  "@home" = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.packages = with pkgs; [
      lazygit
    ];

    programs.git = {
      enable = true;
      userName = "jkz";
      userEmail = "j.k.zwaan@gmail.com";
      extraConfig = {
        push = {autoSetupRemote = true;};
        sendmail = {
          enable = true;
          smtpServer = "smtp.gmail.com";
          smtpUser = "j.k.zwaan@gmail.com";
          smtpServerPort = 587;
          smtpEncryption = "tls";
        };
      };
      aliases = {
       amend = "commit --amend --no-edit";
       pfl = "push --force-with-lease";
       tree = "log --graph --oneline --all";
       line = "log --oneline";
       s = "status";
      };
      ignores = lib.splitString "\n" (builtins.readFile ./.gitignore_global);
    };

    programs.gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      settings = {
       git_protocol = "ssh";
       prompt = "enabled";
      };
    };
  };
}
