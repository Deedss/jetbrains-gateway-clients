FROM docker.io/fedora:latest
# --------------------------------------------------
# Base packages
# --------------------------------------------------
RUN dnf update -y && \
    dnf install -y --setopt=install_weak_deps=False \
    python3 \
    curl \
    jq && \
    dnf clean all
WORKDIR /root
# --------------------------------------------------
# JetBrains downloader
# --------------------------------------------------
ARG JETBRAINS_TOOL=jetbrains-clients-downloader-linux-x86_64-2149
ARG JETBRAINS_DOWNLOAD_URL=https://download.jetbrains.com/idea/code-with-me/backend/${JETBRAINS_TOOL}.tar.gz
ARG JETBRAINS_TOOL_BIN=/root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader
ARG JETBRAINS_CLIENTS_DIR=/root/jetbrains-server/clients
ARG JETBRAINS_BACKEND_DIR=/root/jetbrains-server
RUN curl -L ${JETBRAINS_DOWNLOAD_URL} -o ${JETBRAINS_TOOL}.tar.gz && \
    tar -xf ${JETBRAINS_TOOL}.tar.gz && \
    rm -f ${JETBRAINS_TOOL}.tar.gz
# --------------------------------------------------
# Per-IDE build filters (leave empty to auto-resolve
# from the JetBrains API using IDE_VERSION below)
# IDE_VERSION is always based on last stable major release (e.g. 2025.3)
# --------------------------------------------------
ARG IDE_VERSION=2025.3
ARG INTELLIJ_BUILD=
ARG RUSTROVER_BUILD=
ARG CLION_BUILD=
ARG PYCHARM_BUILD=
# --------------------------------------------------
# Resolve missing build numbers via JetBrains API
# --------------------------------------------------
RUN if [ -z "${INTELLIJ_BUILD}" ] || [ -z "${RUSTROVER_BUILD}" ] || [ -z "${CLION_BUILD}" ] || [ -z "${PYCHARM_BUILD}" ]; then \
        echo "Fetching build numbers from JetBrains API for missing IDEs..." && \
        API_RESPONSE=$(curl -s "https://data.services.jetbrains.com/products/releases?code=CL,IU,RR,PY&majorVersion=${IDE_VERSION}&latest=true") && \
        [ -z "${INTELLIJ_BUILD}" ]  && echo "INTELLIJ_BUILD_API=$(echo  "${API_RESPONSE}" | jq -r '.IU[0].build')"  >> /root/builds_api.env; \
        [ -z "${RUSTROVER_BUILD}" ] && echo "RUSTROVER_BUILD_API=$(echo "${API_RESPONSE}" | jq -r '.RR[0].build')"  >> /root/builds_api.env; \
        [ -z "${CLION_BUILD}" ]     && echo "CLION_BUILD_API=$(echo     "${API_RESPONSE}" | jq -r '.CL[0].build')"  >> /root/builds_api.env; \
        [ -z "${PYCHARM_BUILD}" ]   && echo "PYCHARM_BUILD_API=$(echo   "${API_RESPONSE}" | jq -r '.PCP[0].build')" >> /root/builds_api.env; \
        echo "Resolved builds:" && cat /root/builds_api.env; \
    else \
        echo "All build numbers provided, skipping API resolution."; \
    fi && \
    touch /root/builds_api.env
# --------------------------------------------------
# Download commands
# --------------------------------------------------
ARG CLIENT_COMMAND="--platforms-filter linux-x64 --build-filter"
ARG BACKEND_COMMAND="--download-backends --platforms-filter linux-x64 --build-filter"
# --------------------------------------------------
# Download IntelliJ (client + backend)
# --------------------------------------------------
RUN . /root/builds_api.env; \
    BUILD="${INTELLIJ_BUILD:-${INTELLIJ_BUILD_API}}"; \
    echo "Downloading IntelliJ build ${BUILD}..." && \
    ${JETBRAINS_TOOL_BIN} ${CLIENT_COMMAND} ${BUILD} --products-filter IU ${JETBRAINS_CLIENTS_DIR} && \
    ${JETBRAINS_TOOL_BIN} ${BACKEND_COMMAND} ${BUILD} --products-filter IU ${JETBRAINS_BACKEND_DIR}
# --------------------------------------------------
# Download RustRover (client + backend)
# --------------------------------------------------
RUN . /root/builds_api.env; \
    BUILD="${RUSTROVER_BUILD:-${RUSTROVER_BUILD_API}}"; \
    echo "Downloading RustRover build ${BUILD}..." && \
    ${JETBRAINS_TOOL_BIN} ${CLIENT_COMMAND} ${BUILD} --products-filter RR ${JETBRAINS_CLIENTS_DIR} && \
    ${JETBRAINS_TOOL_BIN} ${BACKEND_COMMAND} ${BUILD} --products-filter RR ${JETBRAINS_BACKEND_DIR}
# --------------------------------------------------
# Download CLion (client + backend)
# --------------------------------------------------
RUN . /root/builds_api.env; \
    BUILD="${CLION_BUILD:-${CLION_BUILD_API}}"; \
    echo "Downloading CLion build ${BUILD}..." && \
    ${JETBRAINS_TOOL_BIN} ${CLIENT_COMMAND} ${BUILD} --products-filter CL ${JETBRAINS_CLIENTS_DIR} && \
    ${JETBRAINS_TOOL_BIN} ${BACKEND_COMMAND} ${BUILD} --products-filter CL ${JETBRAINS_BACKEND_DIR}
# --------------------------------------------------
# Download PyCharm (client + backend)
# --------------------------------------------------
RUN . /root/builds_api.env; \
    BUILD="${PYCHARM_BUILD:-${PYCHARM_BUILD_API}}"; \
    echo "Downloading PyCharm build ${BUILD}..." && \
    ${JETBRAINS_TOOL_BIN} ${CLIENT_COMMAND} ${BUILD} --products-filter PY ${JETBRAINS_CLIENTS_DIR} && \
    ${JETBRAINS_TOOL_BIN} ${BACKEND_COMMAND} ${BUILD} --products-filter PY ${JETBRAINS_BACKEND_DIR}
