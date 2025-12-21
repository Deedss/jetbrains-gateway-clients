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

ARG IDE_VERSION=2025.3

RUN curl -L ${JETBRAINS_DOWNLOAD_URL} -o ${JETBRAINS_TOOL}.tar.gz && \
    tar -xf ${JETBRAINS_TOOL}.tar.gz && \
    rm -f ${JETBRAINS_TOOL}.tar.gz

# --------------------------------------------------
# Resolve all JetBrains stable build numbers
# --------------------------------------------------
RUN echo "Resolving all JetBrains stable build numbers..." && \
    curl -s "https://data.services.jetbrains.com/products/releases?code=CL,IU,RR,PY&latest=true" \
    | jq -r '\
    "CLION_BUILD=\(.CL[0].build)", \
    "INTELLIJ_BUILD=\(.IIU[0].build)", \
    "RUSTROVER_BUILD=\(.RR[0].build)", \
    "PYCHARM_BUILD=\(.PCP[0].build)"\
    ' > /root/builds.env && \
    cat /root/builds.env

# --------------------------------------------------
# Download commands
# --------------------------------------------------
ARG CLIENT_COMMAND="--platforms-filter linux-x64 --verbose --build-filter"
ARG BACKEND_COMMAND="--download-backends --platforms-filter linux-x64 --verbose --build-filter"

# --------------------------------------------------
# Download IntelliJ (client + backend)
# --------------------------------------------------
RUN . /root/builds.env && \
    ${JETBRAINS_TOOL_BIN} ${CLIENT_COMMAND} ${INTELLIJ_BUILD} --products-filter IU ${JETBRAINS_CLIENTS_DIR} && \
    ${JETBRAINS_TOOL_BIN} ${BACKEND_COMMAND} ${INTELLIJ_BUILD} --products-filter IU ${JETBRAINS_BACKEND_DIR}

# # --------------------------------------------------
# # Download RustRover (client + backend)
# # --------------------------------------------------
RUN . /root/builds.env && \
    ${JETBRAINS_TOOL_BIN} ${CLIENT_COMMAND} ${RUSTROVER_BUILD} --products-filter RR ${JETBRAINS_CLIENTS_DIR} && \
    ${JETBRAINS_TOOL_BIN} ${BACKEND_COMMAND} ${RUSTROVER_BUILD} --products-filter RR ${JETBRAINS_BACKEND_DIR}

# --------------------------------------------------
# Download CLion (client + backend)
# --------------------------------------------------
RUN . /root/builds.env && \
    ${JETBRAINS_TOOL_BIN} ${CLIENT_COMMAND} ${CLION_BUILD} --products-filter CL ${JETBRAINS_CLIENTS_DIR} && \
    ${JETBRAINS_TOOL_BIN} ${BACKEND_COMMAND} ${CLION_BUILD} --products-filter CL ${JETBRAINS_BACKEND_DIR}

# --------------------------------------------------
# Download PyCharm (client + backend)
# --------------------------------------------------
RUN . /root/builds.env && \
    ${JETBRAINS_TOOL_BIN} ${CLIENT_COMMAND} ${PYCHARM_BUILD} --products-filter PY ${JETBRAINS_CLIENTS_DIR} && \
    ${JETBRAINS_TOOL_BIN} ${BACKEND_COMMAND} ${PYCHARM_BUILD} --products-filter PY ${JETBRAINS_BACKEND_DIR}
