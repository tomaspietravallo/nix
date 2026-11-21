{ pkgs, ... }:

{
  imports = [
    ../../modules/darwin/development.nix
    ../../modules/darwin/applications.nix
    ../../modules/darwin/privacy.nix
    ../../modules/shared/npm.nix
    ../../modules/darwin/raycast.nix
    ../../modules/darwin/keyboard.nix
    ../../modules/darwin/fonts.nix
    ../../secrets
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.overlays = [
    (_: prev: {
      pre-commit = prev.pre-commit.override {
        dotnetCorePackages = { sdk_8_0-source = { meta.platforms = [ ]; }; };
      };
    })
  ];

  system.primaryUser = "tomaspietravallo";

  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.0;
  };

  nix.package = pkgs.lixPackageSets.stable.lix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  homebrew.enable = true;

  system.stateVersion = 6;
}
