{pkgs, ...}: {
  languages.nix.enable = true;
  pre-commit.hooks = {
    alejandra.enable = true;
    commitizen.enable = true;
    mdsh.enable = true;
    prettier.enable = true;
  };
  packages = [pkgs.bashInteractive];
  scripts = {
    enable-odoo-devenv-tools = {
      description = "Enable odoo devenv tools";
      exec = ''
        #!/usr/bin/env bash

        WORKSPACE_PATH=$(dirname $DEVENV_ROOT)
        # Ask for workspace path (default to one level up from DEVENV_ROOT)
        read -p "Workspace path [$WORKSPACE_PATH]: " WORKSPACE_PATH
        WORKSPACE_PATH=''${WORKSPACE_PATH:-$(dirname $DEVENV_ROOT)}

        echo "Enabling Odoo development tools in $WORKSPACE_PATH"
        read -p "Are you sure? [y/N] " -n 1 -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]
        then
            echo "Aborted"
            exit 1
        fi

        # Copy the workspace files
        cp -r $DEVENV_ROOT/tooling/_workspace/* $WORKSPACE_PATH
        mv $WORKSPACE_PATH/_envrc $WORKSPACE_PATH/.envrc
        mv $WORKSPACE_PATH/_vscode $WORKSPACE_PATH/.vscode

        # Allow direnv
        pushd $WORKSPACE_PATH > /dev/null
        direnv allow
        popd > /dev/null

        echo "Done"
      '';
    };
  };
}
