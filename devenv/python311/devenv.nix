{pkgs, ...}: let
  requirements = ../../odoo/community/requirements.txt;
in {
  scripts.activate-virtualenv-python311 = {
    description = "Activate virtualenv for python311";
    exec = ''
      # Make sure any tools are not attempting to use the python interpreter from any
      # existing virtual environment. For instance if devenv was started within an venv.
      unset VIRTUAL_ENV

      VENV_PATH="$DEVENV_STATE/venv/python311"

      COMMAND="source $VENV_PATH/bin/activate"
      if [ -d "$VENV_PATH" ]
      then
        echo -e "\e[34mYou need to run manually...\e[0m"
        echo -e "\e[33m$COMMAND\e[0m"
      else
        echo -e "\e[34mCreating Python venv...\e[0m"
        ${pkgs.python311}/bin/python -m venv "$VENV_PATH"

        echo -e "\e[34mEntering Python venv...\e[0m"
        source "$VENV_PATH"/bin/activate

        echo -e "\e[34mUpgrading pip...\e[0m"
        "$VENV_PATH"/bin/pip install --upgrade pip

        echo -e "\e[34mInstalling requirements...\e[0m"
        "$VENV_PATH"/bin/pip install wheel
        "$VENV_PATH"/bin/pip install ipython
        "$VENV_PATH"/bin/pip install inotify
        "$VENV_PATH"/bin/pip install libsass
        "$VENV_PATH"/bin/pip install -r ${requirements}
      fi
    '';
  };
}
