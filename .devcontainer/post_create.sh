#!/usr/bin/env bash
set -eux

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

# Setting up Odoo main repositories
.devcontainer/odoo/bin/setup-odoo-repository odoo community
.devcontainer/odoo/bin/setup-odoo-repository enterprise
.devcontainer/odoo/bin/install-odoo-requirements

# Enabling web tooling
yes "" | src/community/addons/web/tooling/enable.sh

# Setting up pre-commit hooks
.devcontainer/odoo/bin/setup-pre-commit
