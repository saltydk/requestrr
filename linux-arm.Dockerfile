FROM hotio/dotnetcore@sha256:3ed4d3982ca7336a7727ab4dd09669861f20c65a319db813b4770371c40e5bcd

EXPOSE 4545

ARG REQUESTRR_VERSION
RUN zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${REQUESTRR_VERSION}/requestrr-linux-arm.zip" && unzip -q "${zipfile}" -d "${APP_DIR}" && rm "${zipfile}" && \
    mv "${APP_DIR}/requestrr-linux-arm" "${APP_DIR}/bin" && \
    chmod -R u=rwX,go=rX "${APP_DIR}" && \
    rmdir "${APP_DIR}/bin/config" && \
    ln -s "${CONFIG_DIR}/app" "${APP_DIR}/bin/config" && \
    chmod -R ugo+x "${APP_DIR}/bin/Requestrr.WebApi"

COPY root/ /
