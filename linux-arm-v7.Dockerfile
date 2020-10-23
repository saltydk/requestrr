FROM ubuntu:focal as builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG VERSION

RUN apt update && \
    apt install -y unzip curl && \
    zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${VERSION}/requestrr-linux-arm.zip" && unzip -q "${zipfile}" -d "/" && \
    rmdir "/requestrr-linux-arm/config" && \
    chmod -R u=rwX,go=rX "/requestrr-linux-arm/" && \
    chmod -R ugo+x "/requestrr-linux-arm/Requestrr.WebApi"

FROM hotio/base@sha256:622ef0f31981daca602e0944876c1eca5af347ff67d83149ead7d9d124963fe7

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
