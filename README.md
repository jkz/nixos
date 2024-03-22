jkz's NixOS configuration


Currently running on a windows machine inside WSL.

Installation

```
# Store this wherever you want, I use my home dir
nix run nixpkgs#git -- clone https://github.com/jkz/nixos
cd nixos

# WARNING: This implies complete destruction of any existing configuration
sudo rm -rf /etc/nixos
sudo ln -s $(pwd) /etc/nixos

sudo nixos-rebuild switch
```
