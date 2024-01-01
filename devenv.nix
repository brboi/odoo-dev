{pkgs, ...}: let
  requirements = ./odoo/community/requirements.txt;
in {
  languages.nix.enable = true;
  pre-commit.hooks = {
    alejandra.enable = true;
    commitizen.enable = true;
    mdsh.enable = true;
    prettier.enable = true;
  };

  packages = with pkgs; [
    git
    nodejs_20
    nodePackages_latest.rtlcss

    # Odoo deps for requirements.txt
    cyrus_sasl.dev
    gcc
    gsasl
    openldap

    # # Python
    # python310

    # # Python (for Odoo before 16.0)
    # python38

    # # Python
    # python311Packages.ipdb
    # python311Packages.libsass
    # python311Packages.pip
    # python311Packages.pq
    # python311Packages.pyopenssl
    # python311Packages.pypdf2
    # python311Packages.python-ldap
    # python311Packages.setuptools
    # python311Packages.virtualenv
  ];

  #   scripts."start-venv.sh".exec = ''
  #     # Make sure any tools are not attempting to use the python interpreter from any
  #     # existing virtual environment. For instance if devenv was started within an venv.
  #     unset VIRTUAL_ENV

  #     # One mandatory argument: the python version to use. i.e. python3.8
  #     if [ -z "$1" ]
  #     then
  #       echo -e "\e[31mMissing argument: python version to use. i.e. python3.8\e[0m"
  #       exit 1
  #     fi

  #     # Check if the python version is available
  #     if ! command -v $1 &> /dev/null
  #     then
  #       echo -e "\e[31m'$1' is not available as a python interpreter\e[0m"
  #       exit 1
  #     elif [[ ! $1 =~ ^python ]]
  #     then
  #       echo -e "\e[31m'$1' is not a python interpreter\e[0m"
  #       exit 1
  #     fi

  #     VENV_PATH="$DEVENV_STATE/venv/$1"
  # devenv
  #     if [ -d "$VENV_PATH" ]
  #     then
  #       echo -e "\e[34mEntering Python venv...\e[0m"
  #       source "$VENV_PATH"/bin/activate
  #       # echo -e "\e[34mSet ACTIVATE_VENV_PATH...\e[0m"
  #       # export ACTIVATE_VENV_PATH="$VENV_PATH"/bin/activate
  #       # echo -e "\e[34mRun the following to activate the virtualenv...\e[0m"
  #       # echo -e "\e[33msource \$ACTIVATE_VENV_PATH\e[0m"
  #     else
  #       echo -e "\e[34mCreating Python venv...\e[0m"
  #       $1 -m venv "$VENV_PATH"
  #       echo -e "\e[34mEntering Python venv...\e[0m"
  #       source "$VENV_PATH"/bin/activate
  #       echo -e "\e[34mInstalling requirements...\e[0m"
  #       "$VENV_PATH"/bin/pip install wheel
  #       "$VENV_PATH"/bin/pip install ipython
  #       "$VENV_PATH"/bin/pip install inotify
  #       "$VENV_PATH"/bin/pip install -r ${requirements}
  #     fi
  #       source "$VENV_PATH"/bin/activate

  #   '';

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

      # Args
      # db_name
      db_name=$1
      other_args="''${*:2}"

      # Command to run
      # $DEVENV_ROOT/odoo/community/odoo-bin -c ./odoo.conf --dev=all -d $db_name $other_args
      command="$DEVENV_ROOT/odoo/community/odoo-bin -c ./odoo.conf --dev=all -d $db_name $other_args"

      echo "!! Review the command to run:"
      echo -e "\e[33m$command\e[0m"
      read -p "Press enter to continue"

      # Run command
      $command
    '';
  };
}
