{
  "@home" = {
    config,
    flake-inputs,
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
      };
      aliases = {
       amend = "commit --amend --no-edit";
       pfl = "push --force-with-lease";
       tree = "log --graph --oneline --all";
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
