# Odoo Dev

## What is it?
A dev container that holds a full-featured development environment for Odoo.
It should help you set up your work environment in minutes.

## Getting started

Requirements
  > - git (make sure your preferred authentication method is configured)
  > - docker
  > - vscode
  > - install vscode recommended devcontainer extension `ms-vscode-remote.remote-containers`

Then, you should:
- clone this repo
- launch the dev container through the vscode extension.

After the dev container's creation, some repositories will get cloned in `src` folder:
- `odoo` repository into `src/community` folder

### Setup more Odoo repositories
#### Pick It Yourself
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

#### The whole stuff
If you want to set up (almost) all Odoo repositories:
```sh
setup-all-odoo-repositories
```

Check the file that has the same name of this command in order to see what repos
will get setuped.

## Cool features

- No dependencies/requirements hassle, everything
- VSCode Odoo's official extensions are pre-installed
  - [Odoo Language Server](https://marketplace.visualstudio.com/items?itemName=Odoo.odoo)
  - [OWL Vision](https://marketplace.visualstudio.com/items?itemName=Odoo.owl-vision)
- Some VSCode launch configurations tailored for Odoo are shipped
- A [Cloudbeaver](https://github.com/dbeaver/cloudbeaver) service is preconfigured.
  It's a web-based database client.
  Check http://localhost:8888 when the devcontainer is running.
- A [Mailpit](https://github.com/axllent/mailpit) service is preconfigured.
  It's an email capture tool for developers.
  Check http://localhost:8825 when the devcontainer is running.

### Mailpit
It ships with mailpit ()

# Credits

https://github.com/odoo-it/docker-odoo
