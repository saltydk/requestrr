FROM ubuntu:focal as builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG VERSION

RUN apt update && \
    apt install -y unzip curl && \
    zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${VERSION}/requestrr-linux-arm64.zip" && unzip -q "${zipfile}" -d "/" && \
    rmdir "/requestrr-linux-arm64/config" && \
    chmod -R u=rwX,go=rX "/requestrr-linux-arm64/" && \
    chmod -R ugo+x "/requestrr-linux-arm64/Requestrr.WebApi"

FROM hotio/base@sha256:612a1f6dff8e15f5ec842afab16e507c455b6c9cd6518bfd0102242499306168

EXPOSE 4545

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        libicu66 && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY --from=builder "/requestrr-linux-arm64/" "${APP_DIR}/"

RUN ln -s "${CONFIG_DIR}/app" "${APP_DIR}/config"

COPY root/ /
