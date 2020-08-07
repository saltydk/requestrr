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
    dotnet publish -c release -o publish -r linux-musl-x64

FROM hotio/base@sha256:7a632e4f16bbbe10d2aaab75a8e7cff3ae868bb7d06e9a10182e385739f9fc7e

EXPOSE 4545

RUN apk add --no-cache libintl libstdc++ icu-libs

COPY --from=builder "/build/Requestrr.WebApi/publish/" "${APP_DIR}/"

RUN chmod -R u=rwX,go=rX "${APP_DIR}" && \
    ln -s "${CONFIG_DIR}/app" "${APP_DIR}/config" && \
    chmod -R ugo+x "${APP_DIR}/Requestrr.WebApi"

COPY root/ /
