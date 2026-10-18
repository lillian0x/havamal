{
  description = "flux manifests repo with pre-commit hooks";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };
  outputs = inputs @ {
    nixpkgs,
    flake-parts,
    systems,
    git-hooks,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import systems;
      imports = [
        git-hooks.flakeModule
      ];
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
      in {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfreePredicate = pkg:
              builtins.elem (nixpkgs.lib.getName pkg) [
              ];
          };
        };
        pre-commit.settings.hooks = {
          alejandra.enable = true;
          terraform-format.enable = true;
          terraform-validate.enable = true;
        };
        formatter = pkgs.writeShellScriptBin "pre-commit-run" ''
          ${pkgs.lib.getExe config.pre-commit.settings.package} run --all-files --config ${config.pre-commit.settings.configFile}
        '';
        devShells.default = pkgs.mkShell {
          inherit (config.pre-commit) shellHook;
          buildInputs = with pkgs;
            [
              opentofu
            ]
            ++ config.pre-commit.settings.enabledPackages;
        };
      };
    };
}
