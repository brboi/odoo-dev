{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
    # https://lazamar.co.uk/nix-versions/?package=wkhtmltopdf&version=0.12.5&fullName=wkhtmltopdf-0.12.5&keyName=wkhtmltopdf&revision=096bad8d75f1445e622d07faccce2e8ff43956c5&channel=nixos-20.03#instructions
    nixos-20_03-pkgs = import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/096bad8d75f1445e622d07faccce2e8ff43956c5.tar.gz";
    }) {};
  in {
    devenv-up = self.devShell.x86_64-linux.config.procfileScript;
    devShell."x86_64-linux" = devenv.lib.mkShell {
      inherit inputs pkgs;
      modules = [
        {
          pre-commit.hooks = {
            alejandra.enable = true;
            commitizen.enable = true;
            mdsh.enable = true;
            prettier.enable = true;
          };

          packages = with pkgs; [
            bashInteractive
            git
            nodejs_20

            # wkhtmltopdf 0.12.5
            nixos-20_03-pkgs.wkhtmltopdf

            # Odoo deps for requirements.txt
            cyrus_sasl.dev
            gcc
            gsasl
            openldap

            # Python
            python311Packages.ipdb
            python311Packages.libsass
            python311Packages.pip
            python311Packages.pq
            python311Packages.pyopenssl
            python311Packages.pypdf2
            python311Packages.python-ldap
            python311Packages.setuptools
            python311Packages.virtualenv
          ];

          languages = {
            nix.enable = true;
            javascript.enable = true;
            python = {
              enable = true;
              version = "3.11";
              venv.enable = true;
            };
          };

          enterShell = ''
            export PATH=result/local/bin:$PATH
            export PYTHONPATH=`pwd`/$VENV/${pkgs.python.sitePackages}/:$PYTHONPATH

            # Allow the use of wheels.
            SOURCE_DATE_EPOCH=$(date +%s)
            VENV=.venv
            REQUIREMENTS=odoo/community/requirements.txt
            if test ! -d $VENV; then
              # First time, create a virtualenv to use for building.
              python -m venv $VENV
              source $VENV/bin/activate

              # Let's install some useful packages.
              pip install wheel
              pip install inotify ipython
              npm install rtlcss

              if test ! -f $REQUIREMENTS; then
                # If there is no requirements.txt,
                # we need to initialize the submodules first.
                git submodule update --init --recursive --remote
                git submodule foreach git pull origin master
                git submodule foreach git checkout master
                # Install odoo requirements.
                pip install -r $REQUIREMENTS
              fi

              # Setup proper submodules remotes
              pushd odoo/community
              git config remote.origin.url git@github.com:odoo/odoo.git
              git config remote.origin.pushurl git@github.com:odoo/odoo.git
              git config remote.dev.url git@github.com:odoo-dev/odoo.git
              git config remote.dev.pushurl git@github.com:odoo-dev/odoo.git
              git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
              git remote set-branches origin '*'
              popd

              pushd odoo/enterprise
              git config remote.origin.url git@github.com:odoo/enterprise.git
              git config remote.origin.pushurl git@github.com:odoo/enterprise.git
              git config remote.dev.url git@github.com:odoo-dev/enterprise.git
              git config remote.dev.pushurl git@github.com:odoo-dev/enterprise.git
              git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
              git remote set-branches origin '*'
              popd

              pushd odoo/industry
              git config remote.origin.url git@github.com:odoo/industry.git
              git config remote.origin.pushurl git@github.com:odoo/industry.git
              git config remote.dev.url git@github.com:odoo-dev/industry.git
              git config remote.dev.pushurl git@github.com:odoo-dev/industry.git
              git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
              git remote set-branches origin '*'
              popd

              pushd odoo/design-themes
              git config remote.origin.url git@github.com:odoo/design-themes.git
              git config remote.origin.pushurl git@github.com:odoo/design-themes.git
              git config remote.dev.url git@github.com:odoo-dev/design-themes.git
              git config remote.dev.pushurl git@github.com:odoo-dev/design-themes.git
              git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
              git remote set-branches origin '*'
              popd

              pushd odoo/upgrade-util
              git config remote.origin.url git@github.com:odoo/upgrade-util.git
              git config remote.origin.pushurl git@github.com:odoo/upgrade-util.git
              git config remote.dev.url git@github.com:odoo-dev/upgrade-util.git
              git config remote.dev.pushurl git@github.com:odoo-dev/upgrade-util.git
              git config --add remote.dev.fetch '+refs/heads/*:refs/remotes/dev/*'
              git remote set-branches origin '*'
              popd

              pushd odoo/upgrade
              git config remote.origin.url git@github.com:odoo/upgrade.git
              git config remote.origin.pushurl git@github.com:odoo/upgrade.git
              git remote set-branches origin '*'
              popd

              pushd odoo/documentation
              git config remote.origin.url git@github.com:odoo/documentation.git
              git config remote.origin.pushurl git@github.com:odoo/documentation.git
              git remote set-branches origin '*'
              popd

            fi
            source $VENV/bin/activate
          '';

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

          scripts = {
            # TODO: make this script user friendly with nice CLI options.
            odoo-dev.exec = ''
              $DEVENV_ROOT/odoo/community/odoo-bin -c ./odoo.conf --dev=all -d odoo -i web
            '';
          };
        }
      ];
    };
  };
}
