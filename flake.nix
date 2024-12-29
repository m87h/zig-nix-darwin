{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/7cc0bff31a3a705d3ac4fdceb030a17239412210";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    zig-overlay,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        zig = zig-overlay.packages.${system}.master.overrideAttrs {
          inherit (pkgs.zig) meta;
        };

        nativeBuildInputs = [
          zig
          (pkgs.zig.hook.override { inherit zig; })
        ];
      in {
        devShells.default = pkgs.mkShell { inherit nativeBuildInputs; };

        packages.default = pkgs.stdenv.mkDerivation {
          pname = "zig-nix-darwin";
          version = "0.0.0";
          src = ./.;

          inherit nativeBuildInputs;
        };
      }
    );
}
