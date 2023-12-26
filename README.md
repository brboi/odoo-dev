# Odoo Development Environment

This repository contains a development environment for Odoo.
It is based on nix flakes and uses [devenv](https://devenv.sh)
as a development environment manager.

## Getting started

### Install nix

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

or with the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### Install [cachix](https://cachix.org/) (optional)

Recommended, speeds up the installation by providing binaries.

```bash
nix profile install nixpkgs#cachix
cachix use devenv
```

### Install [devenv](https://devenv.sh)

```bash
nix profile install --accept-flake-config tarball+https://install.devenv.sh/latest
```

### Clone this repository

This will clone the repository and all submodules.
This will take a while, as the submodules are quite large.
In order to speed things up, we use:

- the `--jobs` option to clone submodules in parallel
- the `--shallow-submodules` option to only clone with a depth of 1

The `--remote-submodules` option is used to clone the submodules from the
remote repository instead of the local one, which will ensure that the
submodules are up to date with the latest commits from the remote repositories.
This will probably result in a dirty git status, as the submodules SHA1 will
be different from the references in this repository's submodules git history.

```bash
git clone --recurse-submodules --remote-submodules --shallow-submodules --jobs=8 git@github.com:brboi/odoo-dev.git
```

In case of failure to fetch submodules, you can run later at
the root of the repository directory:

```bash
git submodule update --init --recursive --remote
```

You won't benefit of the parallel cloning though.

### Activate the development environment

It will automatically install all dependencies.

```bash
cd odoo-dev
devenv shell
```

You may also want an automatic shell activation.
For this you will need another tool called [direnv](https://direnv.net/).
See this [devenv documentation](https://devenv.sh/automatic-shell-activation/).
Once set up, you can allow the automatic shell activation with:

```bash
direnv allow
```

#### In case of failure

If the `./odoo/community/requirements.txt` installation fails, you can try
to install `./requirements.txt` file afterward.

```bash
pip install -r requirements.txt
```

Instead you could also temporarily update the content of
`./odoo/community/requirements.txt` and then run the following command
to retry the installation of all the required dependencies.

```bash
pip install -r odoo/community/requirements.txt
```

## Usage

### Start the development environment processes

This will start postgresql.

```bash
devenv up
```

### CLI tool (work in progress)

```bash
odoo-dev start odoo -i web
```
