# renovate: datasource=docker depName=ghcr.io/containerbase/base
ARG CONTAINERBASE_VERSION=10.3.8

FROM ghcr.io/containerbase/base:${CONTAINERBASE_VERSION} as containerbase

FROM ubuntu:22.04@sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e

ARG CONTAINERBASE_VERSION
ARG APT_HTTP_PROXY

LABEL org.opencontainers.image.source="https://github.com/containerbase/gitpod" \
      org.opencontainers.image.version="${CONTAINERBASE_VERSION}"

# Compatibillity
LABEL org.label-schema.vcs-url="https://github.com/containerbase/gitpod" \
      org.label-schema.version="${CONTAINERBASE_VERSION}"

ARG USER_NAME=gitpod
ARG USER_ID=33333
ARG PRIMARY_GROUP_ID=33333

# Set env and shell
ENV BASH_ENV=/usr/local/etc/env ENV=/usr/local/etc/env PATH=/home/$USER_NAME/bin:$PATH
SHELL ["/bin/bash" , "-c"]

# This entry point ensures that dumb-init is run
ENTRYPOINT [ "docker-entrypoint.sh" ]

# Set up containerbase
COPY --from=containerbase /usr/local/bin/ /usr/local/bin/
COPY --from=containerbase /usr/local/containerbase/ /usr/local/containerbase/
RUN install-containerbase

# add required gitpod and other system packages
RUN set -ex; \
  install-apt \
    g++ \
    locales \
    make \
    shellcheck \
    sudo \
    ; \
  locale-gen en_US.UTF-8; \
  true

# allow sudo without password
RUN set e; \
  echo "$USER_NAME ALL = NOPASSWD: ALL" > /etc/sudoers.d/$USER_NAME; \
  chmod 0440 /etc/sudoers.d/$USERNAME; \
  sudo id; \
  true

# renovate: datasource=github-tags packageName=git/git
RUN install-tool git v2.44.0

# mark all directories as safe
RUN git config --system --add safe.directory '*'

# renovate: datasource=github-releases packageName=moby/moby
RUN install-tool docker v24.0.9

# renovate: datasource=github-releases packageName=containerbase/node-prebuild versioning=node
RUN install-tool node 20.12.0

# enable buildin corepack
RUN corepack enable

# renovate: datasource=github-releases packageName=containerbase/python-prebuild
RUN install-tool python 3.12.2

# prepare some tools for gitpod
#RUN prepare-tool python

USER $USER_NAME
