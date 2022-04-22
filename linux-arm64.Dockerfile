FROM ubuntu:focal as builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG VERSION

RUN apt update && \
    apt install -y unzip curl && \
    zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${VERSION}/requestrr-linux-arm64.zip" && unzip -q "${zipfile}" -d "/" && \
    rmdir "/requestrr-linux-arm64/config" && \
    rmdir "/requestrr-linux-arm64/tmp" && \
    chmod -R u=rwX,go=rX "/requestrr-linux-arm64/" && \
    chmod -R ugo+x "/requestrr-linux-arm64/Requestrr.WebApi"

FROM cr.hotio.dev/hotio/base@sha256:32d1646374b66c1282d1101f04694331ef1a449a784a9c9e1386a6954e31e59e

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

RUN ln -s "${CONFIG_DIR}" "${APP_DIR}/config" && \
    ln -s "/tmp" "${APP_DIR}/tmp"

COPY root/ /
