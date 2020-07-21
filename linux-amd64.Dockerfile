FROM hotio/dotnetcore@sha256:8c001114eb337abf662c02bd197a79d0371c1b3afb856cb0f9f984add14a9ff8

EXPOSE 4545

ARG REQUESTRR_VERSION
RUN zipfile="/tmp/app.zip" && curl -fsSL -o "${zipfile}" "https://github.com/darkalfx/requestrr/releases/download/V${REQUESTRR_VERSION}/requestrr-linux-x64.zip" && unzip -q "${zipfile}" -d "${APP_DIR}" && rm "${zipfile}" && \
    mv "${APP_DIR}/requestrr-linux-x64" "${APP_DIR}/bin" && \
    chmod -R u=rwX,go=rX "${APP_DIR}" && \
    rmdir "${APP_DIR}/bin/config" && \
    ln -s "${CONFIG_DIR}/app" "${APP_DIR}/bin/config" && \
    chmod -R ugo+x "${APP_DIR}/bin/Requestrr.WebApi"

COPY root/ /
