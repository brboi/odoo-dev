{
  pkgs,
  lib,
  ...
}: let
  requirements = ./odoo/community/requirements.txt;
  # https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=096bad8d75f1445e622d07faccce2e8ff43956c5&channel=nixos-20.03#instructions
  old_nixos_revision_for_wkhtmltopdf_0_12_5 = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/096bad8d75f1445e622d07faccce2e8ff43956c5.tar.gz";
  }) {};
in {
  languages.nix.enable = true;
  pre-commit.hooks = {
    alejandra.enable = true;
    commitizen.enable = true;
    mdsh.enable = true;
    prettier.enable = true;
  };

  packages = with pkgs; [
    nodejs_20
    nodePackages_latest.rtlcss

    old_nixos_revision_for_wkhtmltopdf_0_12_5.wkhtmltopdf

    # Odoo deps for requirements.txt
    cyrus_sasl.dev
    gcc
    gsasl
    openldap
  ];

  enterShell = ''
    # If there are no requirements.txt, then the submodules have not been initialized.
    if [ ! -f ${requirements} ]
    then
      echo -e "\e[34mInitializing submodules...\e[0m"
      git submodule update --init --recursive --remote
      git submodule foreach git pull origin master
      git submodule foreach git checkout master
    fi

    # Inform that the python venv should be initialized or activated. (in blue)
    # echo -e "\e[34mUse 'start-venv.sh' to initialize or activate the python venv\e[0m"

    # Finally, inform to check the '# scripts' section of 'devenv info'
    echo -e "\e[34mCheck the '# scripts' section of 'devenv info'\e[0m"
  '';

  scripts = {
    # TODO: make this script user friendly with nice CLI options.
    odoo-dev.exec = ''
      #!/usr/bin/env bash

      # LD_LIBRARY_PATH = "${lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib]}:/run/opengl-driver/lib/:${lib.makeLibraryPath [pkgs.glib]}"

      # Args
      # db_name
      db_name=$1
      other_args="''${*:2}"

      # Command to run
      command="$DEVENV_ROOT/odoo/community/odoo-bin -c $DEVENV_ROOT/odoo.conf --dev=all -d $db_name $other_args"

      echo "!! Review the command to run:"
      echo -e "\e[33m$command\e[0m"
      read -p "Press enter to continue"

      # Run command
      pushd $DEVENV_ROOT
      $command
      popd
    '';
  };
}
