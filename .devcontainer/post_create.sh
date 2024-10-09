#!/usr/bin/env bash
set -euxo pipefail

# Setting access rights
sudo chown -R odoo:odoo /etc/odoo /var/run/odoo
mkdir -p /commandhistory
sudo chown -R odoo:odoo /commandhistory
touch /commandhistory/.bash_history
touch /commandhistory/.zsh_history
sudo chown -R odoo:odoo /commandhistory

# Bootstrapping command history
SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history"
SNIPPET_ZSH="autoload -Uz add-zsh-hook; append_history() { fc -W }; add-zsh-hook precmd append_history; export HISTFILE=/commandhistory/.zsh_history"
echo "$SNIPPET" >> /home/odoo/.bashrc
echo "$SNIPPET_ZSH" >> /home/odoo/.zshrc

# Setting up Odoo community repo
.devcontainer/copy/bin/setup-odoo-repository odoo community
.devcontainer/copy/bin/install-odoo-requirements

# Setting up pre-commit hooks
.devcontainer/copy/bin/setup-pre-commit
