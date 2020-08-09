FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG REQUESTRR_VERSION

RUN apt update && \
    apt install -y software-properties-common && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt install -y gcc g++ make nodejs && \
    mkdir /build && \
    curl -fsSL "https://github.com/darkalfx/requestrr/archive/V${REQUESTRR_VERSION}.tar.gz" | tar xzf - -C "/build" --strip-components=1 && \
    cd "/build/Requestrr.WebApi/ClientApp" && \
    rm -rf package-lock.json && npm install && \
    cd "/build/Requestrr.WebApi" && \
    dotnet publish -c release -o publish -r linux-arm64

FROM hotio/base@sha256:c6bf3ec95093f75a2ff3e6ddfb15f3151da3ef6822a3892db23fa147fec7bed5

EXPOSE 4545

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        libicu60 && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY --from=builder "/build/Requestrr.WebApi/publish/" "${APP_DIR}/"

RUN chmod -R u=rwX,go=rX "${APP_DIR}" && \
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
