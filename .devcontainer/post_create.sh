#!/usr/bin/env bash
set -euxo pipefail

sudo chown -R odoo:odoo /etc/odoo /var/run/odoo
mkdir -p /commandhistory
sudo chown -R odoo:odoo /commandhistory
touch /commandhistory/.bash_history
touch /commandhistory/.zsh_history
sudo chown -R odoo:odoo /commandhistory

SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history"
SNIPPET_ZSH="autoload -Uz add-zsh-hook; append_history() { fc -W }; add-zsh-hook precmd append_history; export HISTFILE=/commandhistory/.zsh_history"

echo "$SNIPPET" >> /home/odoo/.bashrc
echo "$SNIPPET_ZSH" >> /home/odoo/.zshrc

install-odoo-requirements
