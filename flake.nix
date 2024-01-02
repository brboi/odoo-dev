{
  description = "Odoo development environments";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { nixpkgs, flake-utils, self, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=096bad8d75f1445e622d07faccce2e8ff43956c5&channel=nixos-20.03
        old_nixos_revision_for_wkhtmltopdf_0_12_5 = import (builtins.fetchTarball {
          url = "https://github.com/NixOS/nixpkgs/archive/096bad8d75f1445e622d07faccce2e8ff43956c5.tar.gz";
          sha256 = "17chcnlaxf0ljnhf1pggpw19vnrp99zf44dbrnaf8l2djd28v3g8";
        }) { inherit system; };
        requirements = ./odoo/community/requirements.txt;
        commonDeps = with pkgs; [
          old_nixos_revision_for_wkhtmltopdf_0_12_5.wkhtmltopdf

          bashInteractive
          postgresql_14

          nodePackages_latest.rtlcss
        ];
        # lib = (inherit (nixpkgs) lib);
        commonShell = {
          shellHook = ''
            LD_LIBRARY_PATH="${nixpkgs.lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib]}:/run/opengl-driver/lib/:${nixpkgs.lib.makeLibraryPath [pkgs.glib]}"
            # Store python version number
            PYTHON_VERSION=python-$(python --version | cut -d' ' -f2 | cut -d'.' -f1-2)
            # Create virtualenv
            VENV_DIR=.venv/$PYTHON_VERSION
            python -m venv $VENV_DIR
            source $VENV_DIR/bin/activate
            pip install --upgrade pip
            pip install --upgrade wheel
            pip install --upgrade ipython
            pip install --upgrade inotify
            pip install --upgrade libsass
            pip install --upgrade --requirement ./odoo/community/requirements.txt
          '';
        };
      in
      {
        devShells.default = pkgs.mkShell ({
          packages = [pkgs.python310] ++ commonDeps;
        } // commonShell);

        # For Odoo < 17
        devShells.older = pkgs.mkShell ({
          packages = with pkgs; [
            python38
            gcc
          ] ++ commonDeps;
        } // commonShell);
      });
}
