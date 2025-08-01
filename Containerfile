# Use Alma linux as the base image
FROM docker.io/fedora:latest

# Install required packages
RUN dnf update -y && \
    dnf install -y --setopt=install_weak_deps=False \
    python3 && \
    dnf clean all

# Set working directory
WORKDIR /root

# Set environment variables
ARG JETBRAINS_TOOL=jetbrains-clients-downloader-linux-x86_64-1867
ARG JETBRAINS_DOWNLOAD_URL="https://download.jetbrains.com/idea/code-with-me/backend/${JETBRAINS_TOOL}.tar.gz"
ARG JETBRAINS_OUTPUT_DIR=/root/jetbrains-server

ARG INTELLIJ_BUILD=251.27812.49
ARG CLION_BUILD=251.27812.15 
ARG PYCHARM_BUILD=251.26927.90

ARG INTELLIJ_CMD="--platforms-filter linux-x64 --build-filter ${INTELLIJ_BUILD} --products-filter IU --verbose"
ARG CLION_CMD="--platforms-filter linux-x64 --build-filter ${CLION_BUILD} --products-filter CL --verbose"
ARG PYCHARM_CMD="--platforms-filter linux-x64 --build-filter ${PYCHARM_BUILD} --products-filter PY --verbose"

# Download and extract the JetBrains offline download tool
RUN curl -L ${JETBRAINS_DOWNLOAD_URL} -o ${JETBRAINS_TOOL}.tar.gz && \
    tar -xf ${JETBRAINS_TOOL}.tar.gz && \
    rm -f ${JETBRAINS_TOOL}.tar.gz

# # Download IntelliJ, CLion, and PyCharm backends
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader --download-backends ${INTELLIJ_CMD} ${JETBRAINS_OUTPUT_DIR}
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader --download-backends ${CLION_CMD} ${JETBRAINS_OUTPUT_DIR}
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader --download-backends ${PYCHARM_CMD} ${JETBRAINS_OUTPUT_DIR}

# Download full products for IntelliJ, CLion, and PyCharm
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader  ${INTELLIJ_CMD} ${JETBRAINS_OUTPUT_DIR}
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader ${CLION_CMD} ${JETBRAINS_OUTPUT_DIR} 
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader ${PYCHARM_CMD} ${JETBRAINS_OUTPUT_DIR}

RUN mkdir -p ${JETBRAINS_OUTPUT_DIR}/{jbr,clients} && \
    mv ${JETBRAINS_OUTPUT_DIR}/jbr_* ${JETBRAINS_OUTPUT_DIR}/jbr && \
    mv ${JETBRAINS_OUTPUT_DIR}/JetBrainsClient* ${JETBRAINS_OUTPUT_DIR}/clients
