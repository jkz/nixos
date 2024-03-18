# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

# NixOS-WSL specific options are documented on the NixOS-WSL repository:
# https://github.com/nix-community/NixOS-WSL

{ config, lib, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz";
in
{
  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
    (import "${home-manager}/nixos")
  ];

  # This conf is for nixos running on WSL on my windows machine
  wsl = {
    enable = true;
    defaultUser = "jkz";
  };

  environment.variables = {
    EDITOR = "vim";
  };

  nix.settings.experimental-features = "nix-command flakes";

  home-manager.users.jkz = {
    home.stateVersion = "23.11";

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
        conf = "sudo vim /etc/configuration.nix";
        switch = "sudo nixos-rebuild switch";
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
        amend = "commit --amend";
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
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
