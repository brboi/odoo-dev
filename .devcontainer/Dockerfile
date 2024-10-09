ARG PYTHON_VERSION=3.12
ARG DISTRIBUTION=bookworm
FROM python:$PYTHON_VERSION-slim-$DISTRIBUTION

# Multi-arch builds
ARG BUILDPLATFORM
ARG TARGETPLATFORM
RUN echo "I am running on $BUILDPLATFORM, building for $TARGETPLATFORM"

# System environment variables
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV PATH=~/.local/bin:$PATH
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# Default values for postgres
ENV PGHOST=database
ENV PGUSER=odoo
ENV PGPASSWORD=odoo

# Create directory structure
ENV SOURCES=/workspace/src
ENV ETC_ODOO=/etc/odoo
ENV RESOURCES=$ETC_ODOO/.resources

# Config env
ENV ODOO_VERSION=$ODOO_VERSION
ENV ODOO_RC=$ETC_ODOO/odoo.conf

# Add odoo user and directories
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID odoo \
    && useradd --uid $USER_UID --gid $USER_GID -m odoo \
    && apt-get update \
    && apt-get install -y sudo \
    && echo odoo ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/odoo \
    && chmod 0440 /etc/sudoers.d/odoo \
    && sync \
    && chown -R odoo:odoo /home/odoo \
    && mkdir -p ${ETC_ODOO} \
    && chown -R odoo:odoo ${ETC_ODOO} \
    && mkdir -p /var/run/odoo \
    && chown -R odoo:odoo /var/run/odoo \
    && mkdir -p ${RESOURCES} \
    && chown -R odoo:odoo ${RESOURCES} \
    && sync

# Used to persist bash history as per https://code.visualstudio.com/remote/advancedcontainers/persist-bash-history
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    SNIPPET_ZSH="autoload -Uz add-zsh-hook; append_history() { fc -W }; add-zsh-hook precmd append_history; export HISTFILE=/commandhistory/.zsh_history" \
    && mkdir /commandhistory \
    && touch /commandhistory/.bash_history \
    && touch /commandhistory/.zsh_history \
    && chown -R odoo /commandhistory \
    && echo "$SNIPPET" >> "/home/odoo/.bashrc" \
    && echo "$SNIPPET_ZSH" >> "/home/odoo/.zshrc"

# Entrypoint scripts
COPY --chown=odoo:odoo --chmod=775 copy/bin/* /usr/local/bin/
COPY --chown=odoo:odoo --chmod=775 copy/.gitconfig /home/odoo
COPY --chown=odoo:odoo --chmod=777 copy/conf.d $RESOURCES/conf.d
COPY --chown=odoo:odoo --chmod=775 copy/entrypoint.d $RESOURCES/entrypoint.d
COPY --chown=odoo:odoo --chmod=775 copy/entrypoint.sh $RESOURCES/entrypoint.sh

# Install some deps, wkhtmltopdf, postgres-client, and rtlcss
ARG DISTRIBUTION
ARG WKHTMLTOPDF_VERSION=0.12.6
COPY --chmod=700 copy/build/ /build/
RUN apt-get -qq update \
    && xargs -a /build/install/${DISTRIBUTION}/apt-requirements.txt apt-get install -yqq --no-install-recommends \
    && xargs -a /build/install/${DISTRIBUTION}/apt-build-deps.txt apt-get install -yqq --no-install-recommends \
    && /build/install/${DISTRIBUTION}/wkhtmltopdf-${WKHTMLTOPDF_VERSION}.sh \
    && /build/install/${DISTRIBUTION}/postgres-client.sh \
    && pip install --no-cache-dir --requirement /build/extra-requirements.txt \
    && npm install -g rtlcss

# Cleanup
RUN apt-get autopurge -yqq \
    && rm -rf /var/lib/apt/lists/* /tmp/* \
    && sync

# Docker
EXPOSE 8069 8072
VOLUME ["/var/run/odoo", "/workspace", "/commandhistory"]
USER odoo
ENTRYPOINT ${RESOURCES}/entrypoint.sh
