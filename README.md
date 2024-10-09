# Odoo Dev

## Getting started

Requirements
  > - docker
  > - vscode
  > - install vscode recommended devcontainer extension `ms-vscode-remote.remote-containers`

Then, you should:
- clone this repo
- launch the dev container through the vscode extension.

After the dev container's creation, some repositories will get cloned in `src` folder:
- `odoo` repository into `src/community` folder
- `upgrade` repository into `src/upgrade` folder
- `upgrade-util` repository into `src/upgrade-util` folder

## Setup more Odoo repositories
### Pick It Yourself
If you need to work with, say, the enterprise repo, just launch inside
the dev container's shell:
```sh
setup-odoo-repository enterprise
```

> /!\ note that, except for `src/community` and `src/enterprise` all extra-addons
> repositories must be placed inside the `src/extra-addons` folder.
>
> For instance, if you want the `industry` repository,
> launch the following command: `setup-odoo-repository industry extra-addons/industry`.

### The whole stuff
If you want to set up (almost) all Odoo repositories:
```sh
setup-all-odoo-repositories
```

Check the file that has the same name of this command in order to see what repos
will get setuped.

# Credits

https://github.com/odoo-it/docker-odoo
