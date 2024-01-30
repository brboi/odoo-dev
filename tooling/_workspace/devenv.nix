{
  pkgs,
  lib,
  ...
}: let
  # https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=096bad8d75f1445e622d07faccce2e8ff43956c5&channel=nixos-20.03#instructions
  nixpkgs-for-wkhtmltopdf = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/096bad8d75f1445e622d07faccce2e8ff43956c5.tar.gz";
  }) {};
in {
  packages = with pkgs; [
    gcc
    google-chrome
    nixpkgs-for-wkhtmltopdf.wkhtmltopdf
    nodejs_20
  ];

  scripts = {
    odoo-dev = {
      # TODO: make this script user friendly with nice CLI options.
      description = "Run Odoo in dev mode";
      exec = ''
        #!/usr/bin/env bash

        # Args
        # db_name
        db_name=$1
        other_args="''${*:2}"

        # Command to run
        command="$DEVENV_ROOT/community/odoo-bin -c $DEVENV_ROOT/odoo.conf --dev=all -d $db_name $other_args"

        echo "!! Review the command to run:"
        echo -e "\e[33m$command\e[0m"
        read -p "Press enter to continue"

        # Prepare environment
        PATH="${pkgs.rtlcss}/bin:$PATH"
        LD_LIBRARY_PATH="${lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib]}:/run/opengl-driver/lib/:${lib.makeLibraryPath [pkgs.glib]}"

        # Run command
        pushd $DEVENV_ROOT > /dev/null
        $command
        popd > /dev/null
      '';
    };

    setup-repos-and-venvs = {
      description = "Clone and setup repositories, and install python venvs";
      exec = ''
        #!/usr/bin/env bash

        pushd $DEVENV_ROOT > /dev/null

        # Setup repository: community
        if [ ! -d "$DEVENV_ROOT/community" ]
        then
          echo -e "\e[34mPreparing community repository...\e[0m"
          git clone git@github.com:odoo/odoo.git community
          pushd community > /dev/null
          git config remote.origin.url git@github.com:odoo/odoo.git
          git config remote.origin.pushurl git@github.com:odoo/odoo.git
          git config remote.dev.url git@github.com:odoo-dev/odoo.git
          git config remote.dev.pushurl git@github.com:odoo-dev/odoo.git
          git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
          git remote set-branches origin '*'
          popd > /dev/null
        else
          echo -e "\e[34mCommunity repository already cloned...\e[0m"
        fi

        # Setup repository: enterprise
        if [ ! -d "$DEVENV_ROOT/enterprise" ]
        then
          echo -e "\e[34mPreparing enterprise repository...\e[0m"
          git clone git@github.com:odoo/enterprise.git
          pushd enterprise > /dev/null
          git config remote.origin.url git@github.com:odoo/enterprise.git
          git config remote.origin.pushurl git@github.com:odoo/enterprise.git
          git config remote.dev.url git@github.com:odoo-dev/enterprise.git
          git config remote.dev.pushurl git@github.com:odoo-dev/enterprise.git
          git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
          git remote set-branches origin '*'
          popd > /dev/null
        else
          echo -e "\e[34mEnterprise repository already cloned...\e[0m"
        fi

        # Setup repository: industry
        if [ ! -d "$DEVENV_ROOT/industry" ]
        then
          echo -e "\e[34mPreparing industry repository...\e[0m"
          git clone git@github.com:odoo/industry.git
          pushd industry > /dev/null
          git config remote.origin.url git@github.com:odoo/industry.git
          git config remote.origin.pushurl git@github.com:odoo/industry.git
          git config remote.dev.url git@github.com:odoo-dev/industry.git
          git config remote.dev.pushurl git@github.com:odoo-dev/industry.git
          git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
          git remote set-branches origin '*'
          popd > /dev/null
        else
          echo -e "\e[34mIndustry repository already cloned...\e[0m"
        fi

        # Setup repository: design-themes
        if [ ! -d "$DEVENV_ROOT/design-themes" ]
        then
          echo -e "\e[34mPreparing design-themes repository...\e[0m"
          git clone git@github.com:odoo/design-themes.git
          pushd design-themes > /dev/null
          git config remote.origin.url git@github.com:odoo/design-themes.git
          git config remote.origin.pushurl git@github.com:odoo/design-themes.git
          git config remote.dev.url git@github.com:odoo-dev/design-themes.git
          git config remote.dev.pushurl git@github.com:odoo-dev/design-themes.git
          git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
          git remote set-branches origin '*'
          popd > /dev/null
        else
          echo -e "\e[34mDesign-themes repository already cloned...\e[0m"
        fi

        # Setup repository: upgrade-util
        if [ ! -d "$DEVENV_ROOT/upgrade-util" ]
        then
          echo -e "\e[34mPreparing upgrade-util repository...\e[0m"
          git clone git@github.com:odoo/upgrade-util.git
          pushd upgrade-util > /dev/null
          git config remote.origin.url git@github.com:odoo/upgrade-util.git
          git config remote.origin.pushurl git@github.com:odoo/upgrade-util.git
          git config remote.dev.url git@github.com:odoo-dev/upgrade-util.git
          git config remote.dev.pushurl git@github.com:odoo-dev/upgrade-util.git
          git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
          git remote set-branches origin '*'
          popd > /dev/null
        else
          echo -e "\e[34mUpgrade-util repository already cloned...\e[0m"
        fi

        # Setup repository: upgrade
        if [ ! -d "$DEVENV_ROOT/upgrade" ]
        then
          echo -e "\e[34mPreparing upgrade repository...\e[0m"
          git clone git@github.com:odoo/upgrade.git
          pushd upgrade > /dev/null
          git config remote.origin.url git@github.com:odoo/upgrade.git
          git config remote.origin.pushurl git@github.com:odoo/upgrade.git
          git remote set-branches origin '*'
          popd > /dev/null
        else
          echo -e "\e[34mUpgrade repository already cloned...\e[0m"
        fi

        # Setup repository: documentation
        if [ ! -d "$DEVENV_ROOT/documentation" ]
        then
          echo -e "\e[34mPreparing documentation repository...\e[0m"
          git clone git@github.com:odoo/documentation.git
          pushd documentation > /dev/null
          git config remote.origin.url git@github.com:odoo/documentation.git
          git config remote.origin.pushurl git@github.com:odoo/documentation.git
          git remote set-branches origin '*'
          popd > /dev/null
        else
          echo -e "\e[34mDocumentation repository already cloned...\e[0m"
        fi

        # ----------------------------------------------------------------------

        # Make sure any tools are not attempting to use the python interpreter from any
        # existing virtual environment. For instance if devenv was started within an venv.
        unset VIRTUAL_ENV

        # If already installed, inform and ask if we should remove or continue.
        if [ -d "$DEVENV_ROOT/.venv" ]
        then
          echo -e "\e[34mPython venv already exists...\e[0m"
          echo -e "\e[33m$DEVENV_ROOT/.venv\e[0m"
          echo -e "\e[34mDo you want to remove the existing venv folder and install a new one? [y/n]\e[0m"
          read -r REMOVE
          if [ "$REMOVE" = "y" ]
          then
            echo -e "\e[34mRemoving Python venv...\e[0m"
            rm -rf "$DEVENV_ROOT/.venv"
          else
            echo -e "\e[34mExiting...\e[0m"
            exit 0
          fi
        fi

        # Install python 3.8 venv.
        ${pkgs.python38}/bin/python -m venv "$DEVENV_ROOT/.venv/python38"

        # Install python 3.11 venv.
        ${pkgs.python311}/bin/python -m venv "$DEVENV_ROOT/.venv/python311"

        VERSIONS="python38 python311"
        for VERSION in $VERSIONS
        do
          VENV_PATH="$DEVENV_ROOT/.venv/$VERSION"

          echo -e "\e[34mEntering Python venv...\e[0m"
          source "$VENV_PATH"/bin/activate

          echo -e "\e[34mUpgrading pip...\e[0m"
          "$VENV_PATH"/bin/pip install --upgrade pip

          echo -e "\e[34mInstalling requirements...\e[0m"
          "$VENV_PATH"/bin/pip install --upgrade wheel
          "$VENV_PATH"/bin/pip install --upgrade ipython
          "$VENV_PATH"/bin/pip install --upgrade inotify
          "$VENV_PATH"/bin/pip install --upgrade libsass
          "$VENV_PATH"/bin/pip install --upgrade lxml
          "$VENV_PATH"/bin/pip install --upgrade websocket-client

          # check if DEVENV_ROOT/community/requirements.txt exists
          if [ -f "$DEVENV_ROOT/community/requirements.txt" ]
          then
            echo -e "\e[34mInstalling community requirements...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/community/requirements.txt"
          fi

          # check if DEVENV_ROOT/enterprise/requirements.txt exists
          if [ -f "$DEVENV_ROOT/enterprise/requirements.txt" ]
          then
            echo -e "\e[34mInstalling enterprise requirements...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/enterprise/requirements.txt"
          fi

          # check if DEVENV_ROOT/industry/requirements.txt exists
          if [ -f "$DEVENV_ROOT/industry/requirements.txt" ]
          then
            echo -e "\e[34mInstalling industry requirements...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/industry/requirements.txt"
          fi

          # check if DEVENV_ROOT/design-themes/requirements.txt exists
          if [ -f "$DEVENV_ROOT/design-themes/requirements.txt" ]
          then
            echo -e "\e[34mInstalling design-themes requirements...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/design-themes/requirements.txt"
          fi

          # check if DEVENV_ROOT/upgrade-util/requirements.txt exists
          if [ -f "$DEVENV_ROOT/upgrade-util/requirements.txt" ]
          then
            echo -e "\e[34mInstalling upgrade-util requirements...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/upgrade-util/requirements.txt"
          fi

          # check if DEVENV_ROOT/upgrade-util/requirements-dev.txt exists
          if [ -f "$DEVENV_ROOT/upgrade-util/requirements-dev.txt" ]
          then
            echo -e "\e[34mInstalling upgrade-util requirements-dev...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/upgrade-util/requirements-dev.txt"
          fi

          # check if DEVENV_ROOT/upgrade/requirements.txt exists
          if [ -f "$DEVENV_ROOT/upgrade/requirements.txt" ]
          then
            echo -e "\e[34mInstalling upgrade requirements...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/upgrade/requirements.txt"
          fi

          # check if DEVENV_ROOT/upgrade/requirements-dev.txt exists
          if [ -f "$DEVENV_ROOT/upgrade/requirements-dev.txt" ]
          then
            echo -e "\e[34mInstalling upgrade requirements-dev...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/upgrade/requirements-dev.txt"
          fi

          # check if DEVENV_ROOT/documentation/requirements.txt exists
          if [ -f "$DEVENV_ROOT/documentation/requirements.txt" ]
          then
            echo -e "\e[34mInstalling documentation requirements...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/documentation/requirements.txt"
          fi

          # check if DEVENV_ROOT/documentation/tests/requirements.txt exists
          if [ -f "$DEVENV_ROOT/documentation/tests/requirements.txt" ]
          then
            echo -e "\e[34mInstalling documentation/tests requirements...\e[0m"
            "$VENV_PATH"/bin/pip install --upgrade -r "$DEVENV_ROOT/documentation/tests/requirements.txt"
          fi
        done
      '';
    };
  };

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_14;
    initialScript = ''
      CREATE USER postgres WITH
        SUPERUSER
        PASSWORD 'PostgresqlSuperAdminP@ssw0rd';
      CREATE USER odoo     WITH
        CREATEDB
        PASSWORD 'odoo';
    '';
  };
}
