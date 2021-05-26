FROM ubuntu:focal as builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG VERSION

RUN apt update && \
    apt install -y unzip curl && \
    zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${VERSION}/requestrr-linux-arm.zip" && unzip -q "${zipfile}" -d "/" && \
    rmdir "/requestrr-linux-arm/config" && \
    chmod -R u=rwX,go=rX "/requestrr-linux-arm/" && \
    chmod -R ugo+x "/requestrr-linux-arm/Requestrr.WebApi"

FROM hotio/base@sha256:c2f89b1d07dc559a34179f9f820ea39dfe3bb3b79b934dae72a5c3a086f410de

EXPOSE 4545

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        libicu66 && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY --from=builder "/requestrr-linux-arm/" "${APP_DIR}/"

RUN ln -s "${CONFIG_DIR}" "${APP_DIR}/config"

COPY root/ /
