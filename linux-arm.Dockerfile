FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as builder
ARG DEBIAN_FRONTEND="noninteractive"
ARG REQUESTRR_VERSION

RUN apt update && \
    apt install -y npm && \
    mkdir /build && \
    curl -fsSL "https://github.com/darkalfx/requestrr/archive/V${REQUESTRR_VERSION}.tar.gz" | tar xzf - -C "/build" --strip-components=1 && \
    cd "/build/Requestrr.WebApi/ClientApp" && \
    npm install && \
    cd "/build/Requestrr.WebApi" && \
    dotnet publish -c release -o publish -r linux-arm

FROM hotio/dotnetcore@sha256:3ed4d3982ca7336a7727ab4dd09669861f20c65a319db813b4770371c40e5bcd

EXPOSE 4545

COPY --from=builder "/build/Requestrr.WebApi/publish/*" "${APP_DIR}/"

RUN chmod -R u=rwX,go=rX "${APP_DIR}" && \
    rmdir "${APP_DIR}/config" && \
    ln -s "${CONFIG_DIR}/app" "${APP_DIR}/config" && \
    chmod -R ugo+x "${APP_DIR}/Requestrr.WebApi"

COPY root/ /
