{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
  in {
    devShells.${system} = let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          permittedInsecurePackages = [
            "python-2.7.18.6"
          ];
        };
      };
      python3 = pkgs.python310;
      python2 = pkgs.python2;
      # A set of system dependencies for Python modules.
      # They act as build inputs and are used to configure
      # LD_LIBRARY_PATH in the shell.
      systemPackages = with pkgs; [
        pkg-configUpstream
        ffmpeg_4 # v4 for libavresample
        libsamplerate
        taglib
        libyaml
        # fftw
        chromaprint
        zlib
        cmake
        qt4
      ];
    in {
      default = pkgs.mkShell {
        essentia_src = pkgs.fetchFromGitHub {
          owner = "MTG";
          repo = "essentia";
          rev = "ed59cc48e37ac33ac15b252fc5ad7af4b9ecd51d";
          # tag = "2.1_beta5";
          hash = "sha256-nPw3KxN2vXgAGnQIC5pMxZ35hbveERmvzMLn7vgx4kU=";
        };

        venvDir = ".venv";

        buildInputs =
          [
            # A Python interpreter including the 'venv' module is required to bootstrap the environment.
            (python3.withPackages (ps:
              with ps; [
                setuptools
                wheel
                pyyaml
                numpy
                six
              ]))

            python2
          ]
          ++ systemPackages;

        postVenvCreation = ''
          unset SOURCE_DATE_EPOCH
        '';

        LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath systemPackages}";

        shellHook = ''
          echo "Run ./script.sh"
        '';

        postShellHook = ''
          unset SOURCE_DATE_EPOCH
        '';
      };
    };
  };
}
