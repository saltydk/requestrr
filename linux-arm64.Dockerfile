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

FROM cr.hotio.dev/hotio/base@sha256:12fac806eaf287853299e31f6b39aead42cc2dfe5a8783a55aceeb1c67c34a9b

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
