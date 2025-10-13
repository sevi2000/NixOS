{
  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
}