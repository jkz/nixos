{
  "@home" = {
    config,
    flake-inputs,
    pkgs,
    ...
  }: {
    home.file.".hellorc".source = ./.hellorc;
  };
  "@nixos" = {
    pkgs,
    config,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      hello
    ];
  };
}
