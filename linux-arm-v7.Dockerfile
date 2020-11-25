FROM ubuntu:focal as builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG VERSION

RUN apt update && \
    apt install -y unzip curl && \
    zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${VERSION}/requestrr-linux-arm.zip" && unzip -q "${zipfile}" -d "/" && \
    rmdir "/requestrr-linux-arm/config" && \
    chmod -R u=rwX,go=rX "/requestrr-linux-arm/" && \
    chmod -R ugo+x "/requestrr-linux-arm/Requestrr.WebApi"

FROM hotio/base@sha256:8d867126f2f29fce7964ace0331fc3c91c0d7090d3a13c44f589ec4a06e8c972

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

RUN ln -s "${CONFIG_DIR}/app" "${APP_DIR}/config"

COPY root/ /
