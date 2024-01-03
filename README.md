# Usage

## Postgres

```bash
devenv up
```

## Odoo

Either start Odoo with the CLI

```bash
odoo-dev database_name -i web,project
```

Or with VS Code `launch.json` profiles: `CTRL-K F5`.

# Installation

## Requirements

### Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### direnv

```bash
curl -sfL https://direnv.net/install.sh | bash
```

### devenv

```bash
nix profile install nixpkgs#cachix
cachix use devenv
nix profile install --accept-flake-config tarball+https://install.devenv.sh/latest
```

### direnv hook

Visit https://direnv.net/docs/hook.html and install the direnv hook for your shell.

Then run at the root of this repository:

```bash
direnv allow
```

## Setup

```bash
enable-odoo-devenv-tools
```

And then

```bash
cd your_workspace
direnv allow
setup-repos-and-venvs
```

## Further optional steps

```bash
cd your_workspace/community
./addons/web/tooling/enable.sh
```
