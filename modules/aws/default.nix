{pkgs, ...}: {
  programs.awscli = {
    enable = true;
    package = pkgs.awscli2;
  };
}
