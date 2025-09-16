{
  description = "Janet implementation of Lox, from the book Crafting Interpreters";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems =
        mkOutputs:
        nixpkgs.lib.genAttrs [
          "aarch64-linux"
          "aarch64-darwin"
          "x86_64-darwin"
          "x86_64-linux"
        ] (system: mkOutputs nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        spork = pkgs.stdenv.mkDerivation rec {
          pname = "spork";
          version = "1.0.0";
          src = pkgs.fetchFromGitHub {
            owner = "janet-lang";
            repo = pname;
            rev = "v${version}";
            sha256 = "sha256-na1A3JT8FmtsbdAVAXf+MCMdi0dCdBGqmyNg5wZLy6k=";
          };
          dontConfigure = true;
          buildInputs = [ pkgs.janet ];
          dontBuild = true;
          installPhase = ''
            mkdir $out
            JANET_PATH=$out janet --install .
          '';
          doInstallCheck = true;
          installCheckPhase = ''
            $out/bin/janet-pm --help
          '';
        };
        lox = pkgs.stdenv.mkDerivation {
          pname = "lox";
          version = "0.0.1";
          src = ./.;
          dontConfigure = true;
          buildInputs = [
            pkgs.janet
            self.packages.${pkgs.system}.spork
          ];
          buildPhase = ''
            janet-pm build
          '';
          installPhase = ''
            mkdir -p $out/bin
            mv _build/release/lox $out/bin
          '';
          doInstallCheck = true;
          installCheckPhase = ''
            echo 'print 1;' | $out/bin/lox
          '';
          meta.mainProgram = "lox";
        };
        default = self.packages.${pkgs.system}.lox;
      });

      apps = forAllSystems (pkgs: {
        lox = {
          type = "app";
          program = pkgs.lib.getExe self.packages.${pkgs.system}.lox;
        };
        default = self.apps.${pkgs.system}.lox;
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = [
            pkgs.janet
            self.packages.${pkgs.system}.spork
            self.packages.${pkgs.system}.lox
          ];
        };
      });
    };
}
