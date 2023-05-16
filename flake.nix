{
  description = "djacu's personal site";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.npmlock2nix.url = "github:nix-community/npmlock2nix";
  inputs.npmlock2nix.flake = false;
  inputs.astro-theme-src.url = "github:manuelernestog/astro-modern-personal-website";
  inputs.astro-theme-src.flake = false;

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    npmlock2nix,
    astro-theme-src,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (self: super: {
              npmlock2nix = pkgs.callPackage npmlock2nix {};
            })
          ];
        };

        astro-shell = pkgs.npmlock2nix.v2.shell {
          src = astro-theme-src;
          nodejs = pkgs.nodejs;
          node_modules_mode = "copy";

          node_modules_attrs.npm_config_sharp_libvips_local_prebuilds = "${lib-vips}";
          npm_config_sharp_libvips_local_prebuilds = "${lib-vips}";

          node_modules_attrs.nativeBuildInputs = [pkgs.python3];
        };

        sharp = pkgs.npmlock2nix.v2.shell {
          src = pkgs.fetchFromGitHub {
            owner = "djacu";
            repo = "sharp";
            rev = "7cc7017e9f49647dc54c387ea57e49a6947ee965";
            sha256 = "sha256-u+G8eH+KgR16pv1hKj0TsosnuaZ4OytmqXRlwU9N0kI=";
          };

          nodejs = pkgs.nodejs;
          node_modules_mode = "copy";

          node_modules_attrs.npm_config_sharp_libvips_local_prebuilds = "${lib-vips}";
          npm_config_sharp_libvips_local_prebuilds = "${lib-vips}";

          node_modules_attrs = {
            preBuildPhases = ["preBuildPhase"];
            preBuildPhase = ''
              echo FUCK
              echo $sourceRoot
              exit 123
            '';
          };
        };

        lib-vips = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "libvips";
          version = "8.13.3";
          arch = "linux-x64";
          src = builtins.fetchurl {
            url = "https://github.com/lovell/sharp-libvips/releases/download/v${version}/${pname}-${version}-${arch}.tar.br";
            sha256 = "1jgw7dknfk9w1cwzcj6k98jrnncg1fwxf6jf1hlxpnixrn0a2hdk";
          };
          unpackPhase = ''
            mkdir source
            cp $src ./source/
          '';
          dontPatch = true;
          dontConfigure = true;
          dontBuild = true;
          installPhase = ''
            ls -FhoA .
            ls -FhoA source
            mkdir -p $out/v${version}
            cp -r ./source/* $out/v${version}/${pname}-${version}-${arch}.tar.br
          '';
        };
      in {
        devShells.default = astro-shell;
        devShells.sharp = sharp;
        #devShells.default = pkgs.mkShell {
        #  packages = [
        #    pkgs.alejandra
        #  ];
        #};
        packages.default = lib-vips;
        packages = {
          inherit sharp;
        };
      }
    );
}
