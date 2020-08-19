FROM ubuntu:focal as builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG REQUESTRR_VERSION

RUN apt update && \
    apt install -y unzip curl && \
    zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${REQUESTRR_VERSION}/requestrr-linux-x64.zip" && unzip -q "${zipfile}" -d "/"

FROM hotio/base@sha256:7cd0db216b77704532cecb0fdf8d99e46e8623eaf1d813b689bfd43b78b6ab20

EXPOSE 4545

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        libicu66 && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY --from=builder "/requestrr-linux-x64/" "${APP_DIR}/"

RUN chmod -R u=rwX,go=rX "${APP_DIR}" && \
    rmdir "${APP_DIR}/config" && \
    ln -s "${CONFIG_DIR}/app" "${APP_DIR}/config" && \
    chmod -R ugo+x "${APP_DIR}/Requestrr.WebApi"

COPY root/ /

ARG LABEL_CREATED
LABEL org.opencontainers.image.created=$LABEL_CREATED
ARG LABEL_TITLE
LABEL org.opencontainers.image.title=$LABEL_TITLE
ARG LABEL_REVISION
LABEL org.opencontainers.image.revision=$LABEL_REVISION
ARG LABEL_SOURCE
LABEL org.opencontainers.image.source=$LABEL_SOURCE
ARG LABEL_VENDOR
LABEL org.opencontainers.image.vendor=$LABEL_VENDOR
ARG LABEL_URL
LABEL org.opencontainers.image.url=$LABEL_URL
ARG LABEL_VERSION
LABEL org.opencontainers.image.version=$LABEL_VERSION
