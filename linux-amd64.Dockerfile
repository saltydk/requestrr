FROM ubuntu:focal as builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG VERSION

RUN apt update && \
    apt install -y unzip curl && \
    zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${VERSION}/requestrr-linux-x64.zip" && unzip -q "${zipfile}" -d "/" && \
    rmdir "/requestrr-linux-x64/config" && \
    chmod -R u=rwX,go=rX "/requestrr-linux-x64/" && \
    chmod -R ugo+x "/requestrr-linux-x64/Requestrr.WebApi"

FROM ghcr.io/hotio/base@sha256:029cd66161bb2f8ce8a845f108f2d43872f4b4c290e8122eed7e51d76a6a6b8e

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

RUN ln -s "${CONFIG_DIR}" "${APP_DIR}/config"

COPY root/ /
