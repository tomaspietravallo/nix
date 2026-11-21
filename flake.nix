{
  description = "Nix configuration for macOS and NixOS";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.url = "git+https://github.com/Mic92/sops-nix?shallow=1";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nix-darwin, nixpkgs-stable, sops-nix, ... }: {
    darwinConfigurations."Tomass-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        ./hosts/macbook
        sops-nix.darwinModules.sops
      ];
    };
    nixosConfigurations.nixos = nixpkgs-stable.lib.nixosSystem {
      modules = [
        ./hosts/nixos
        sops-nix.nixosModules.sops
      ];
    };
  };
}
