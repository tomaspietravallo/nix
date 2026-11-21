# Nix configuration

Configurations for the MacBook (nix-darwin) and the NixOS remote development host. macOS uses the existing unstable nixpkgs input; NixOS uses a separate stable 26.05 input.

- `hosts/macbook` and `modules/darwin` contain Mac-specific configuration.
- `hosts/nixos` contains the server and its hardware configuration.
- `modules/shared` contains shared modules.
- `secrets` is a private Git submodule containing encrypted SOPS files and platform-specific integrations. Private age identities stay outside Git.

Initialize the submodule when cloning: `git clone --recurse-submodules <repository-url>`. Ensure submodule changes are committed and pushed to its private remote before updating and pushing the parent gitlink.

The server configuration expects a complete checkout at `/etc/nixos/nix`, and its scheduled updater changes only the `nixpkgs-stable` lock input in that checkout. It does not reboot automatically. Provision the server age recipient before applying the secrets module.

On macOS, the pre-push hook applies the Mac configuration if the pushed changes may affect it. It skips pushes containing only NixOS host modules or README changes. If the hook cannot determine the changed files, it applies the configuration. The hook applies the current working-tree configuration, as it did before the refactor.
