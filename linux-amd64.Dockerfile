FROM ubuntu:focal
LABEL maintainer="hotio"

ENV APP_DIR="/app" CONFIG_DIR="/config" PUID="1000" PGID="1000" UMASK="002" TZ="Etc/UTC" ARGS="" DEBUG="no"
ENV XDG_CONFIG_HOME="${CONFIG_DIR}/.config" XDG_CACHE_HOME="${CONFIG_DIR}/.cache" XDG_DATA_HOME="${CONFIG_DIR}/.local/share" LANG="C.UTF-8" LC_ALL="C.UTF-8"
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

VOLUME ["${CONFIG_DIR}"]
ENTRYPOINT ["/init"]

# install packages
RUN apk add --no-cache tzdata shadow bash curl jq

# make folders
RUN mkdir "${APP_DIR}" && \
# create user
    useradd -u 1000 -U -d "${CONFIG_DIR}" -s /bin/false hotio && \
    usermod -G users hotio

# https://github.com/just-containers/s6-overlay/releases
ARG S6_VERSION=2.0.0.1

# install s6-overlay
RUN curl -fsSL "https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz" | tar xzf - -C /

# Requestrr install
EXPOSE 4545

ARG REQUESTRR_VERSION
RUN zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${REQUESTRR_VERSION}/requestrr-linux-x64.zip" && unzip -q "${zipfile}" -d "${APP_DIR}" && rm "${zipfile}" && \
    mv "${APP_DIR}/requestrr-linux-x64" "${APP_DIR}/bin" && \
    ln -sf "${CONFIG_DIR}/app" "${APP_DIR}/bin/config" && \
    chmod -R u=rwX,go=rX "${APP_DIR}" && \
    chmod -R ugo+x "${APP_DIR}/bin/Requestrr.WebApi"

COPY root/ /
