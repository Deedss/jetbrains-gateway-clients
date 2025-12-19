FROM docker.io/fedora:latest

# Install required packages
RUN dnf update -y && \
    dnf install -y --setopt=install_weak_deps=False \
    python3 && \
    dnf clean all

# Set working directory
WORKDIR /root

# Set environment variables
ARG JETBRAINS_TOOL=jetbrains-clients-downloader-linux-x86_64-2149
ARG JETBRAINS_DOWNLOAD_URL="https://download.jetbrains.com/idea/code-with-me/backend/${JETBRAINS_TOOL}.tar.gz"

ARG INTELLIJ_BUILD=253.29346.138
ARG CLION_BUILD=253.29346.141
ARG PYCHARM_BUILD=253.29346.142

ARG INTELLIJ_CMD="--platforms-filter linux-x64 --build-filter ${INTELLIJ_BUILD} --products-filter IU --verbose"
ARG CLION_CMD="--platforms-filter linux-x64 --build-filter ${CLION_BUILD} --products-filter CL --verbose"
ARG PYCHARM_CMD="--platforms-filter linux-x64 --build-filter ${PYCHARM_BUILD} --products-filter PY --verbose"

ARG JETBRAINS_CLIENTS_DIR=/root/jetbrains-server/clients
ARG JETBRAINS_BACKEND_DIR=/root/jetbrains-server

# Download and extract the JetBrains offline download tool
RUN curl -L ${JETBRAINS_DOWNLOAD_URL} -o ${JETBRAINS_TOOL}.tar.gz && \
    tar -xf ${JETBRAINS_TOOL}.tar.gz && \
    rm -f ${JETBRAINS_TOOL}.tar.gz

# Download full products for IntelliJ, CLion, and PyCharm
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader ${INTELLIJ_CMD} ${JETBRAINS_CLIENTS_DIR}
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader ${CLION_CMD} ${JETBRAINS_CLIENTS_DIR}
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader ${PYCHARM_CMD} ${JETBRAINS_CLIENTS_DIR}

# Download IntelliJ, CLion, and PyCharm backends
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader --download-backends ${INTELLIJ_CMD} ${JETBRAINS_BACKEND_DIR}
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader --download-backends ${CLION_CMD} ${JETBRAINS_BACKEND_DIR}
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader --download-backends ${PYCHARM_CMD} ${JETBRAINS_BACKEND_DIR}
