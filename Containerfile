# Use Red Hat UBI 8 as the base image
FROM registry.access.redhat.com/ubi8/ubi:latest

# Install required packages
RUN dnf update -y && \
    dnf install -y \
        java-1.8.0-openjdk \
        python3 \
        curl && \
    dnf clean all

# Set working directory
WORKDIR /root

# Set environment variables
ARG JETBRAINS_TOOL=jetbrains-clients-downloader-linux-x86_64-1867
ARG JETBRAINS_DOWNLOAD_URL="https://download.jetbrains.com/idea/code-with-me/backend/${JETBRAINS_TOOL}.tar.gz"
ARG JETBRAINS_OUTPUT_DIR=/root/jetbrains-server

ARG INTELLIJ_BUILD=242.21829.142
ARG CLION_BUILD=242.20224.413
ARG PYCHARM_BUILD=242.21829.153

ARG INTELLIJ_CMD="--platforms-filter linux-x64 --build-filter ${INTELLIJ_BUILD} --products-filter IU"
ARG CLION_CMD="--platforms-filter linux-x64 --build-filter ${CLION_BUILD} --products-filter CL"
ARG PYCHARM_CMD="--platforms-filter linux-x64 --build-filter ${PYCHARM_BUILD} --products-filter PY"

# Download and extract the JetBrains offline download tool
RUN curl -L ${JETBRAINS_DOWNLOAD_URL} -o ${JETBRAINS_TOOL}.tar.gz && \
    tar -xf ${JETBRAINS_TOOL}.tar.gz && \
    rm -f ${JETBRAINS_TOOL}.tar.gz

# Download IntelliJ, CLion, and PyCharm backends
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader --download-backends ${INTELLIJ_CMD} ${JETBRAINS_OUTPUT_DIR} && \
    /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader --download-backends ${CLION_CMD} ${JETBRAINS_OUTPUT_DIR} && \
    /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader --download-backends ${PYCHARM_CMD} ${JETBRAINS_OUTPUT_DIR}

# Download full products for IntelliJ, CLion, and PyCharm
RUN /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader  ${INTELLIJ_CMD} ${JETBRAINS_OUTPUT_DIR} && \
    /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader ${CLION_CMD} ${JETBRAINS_OUTPUT_DIR} && \
    /root/${JETBRAINS_TOOL}/bin/jetbrains-clients-downloader ${PYCHARM_CMD} ${JETBRAINS_OUTPUT_DIR}

RUN mkdir -p ${JETBRAINS_OUTPUT_DIR}/{jbr,clients} && \
    mv ${JETBRAINS_OUTPUT_DIR}/jbr_* ${JETBRAINS_OUTPUT_DIR}/jbr && \
    mv ${JETBRAINS_OUTPUT_DIR}/JetBrainsClient* ${JETBRAINS_OUTPUT_DIR}/clients
