{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../secrets/nixos.nix
    ./sandboxes
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "yes";
    PasswordAuthentication = true;
  };
  services.tailscale.enable = true;
  time.timeZone = "America/Argentina/Buenos_Aires";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    curl
    git
    htop
    nano
    tmux
    wget
  ];
  systemd.services.nixos-upgrade.preStart =
    "${pkgs.nix}/bin/nix flake update nixpkgs-stable --flake /etc/nixos/nix";
  system.autoUpgrade = {
    enable = true;
    flake = "path:/etc/nixos/nix#nixos";
    upgrade = false;
    dates = "04:00";
    randomizedDelaySec = "30min";
    allowReboot = false;
  };
  system.stateVersion = "26.05";
}
