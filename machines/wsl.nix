{ flake-inputs, ... }:
{
  imports = [
    # <nixos-wsl/modules>
    flake-inputs.nixos-wsl.nixosModules.wsl
  ];

  # This conf is for nixos running on WSL on my windows machine
  wsl = {
    enable = true;
    defaultUser = "jkz";
  };
}
