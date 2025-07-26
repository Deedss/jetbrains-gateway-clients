# Containerfile: Download JetBrains backend and client
FROM docker.io/fedora:latest

# Install curl, Python, and tar (required by the JetBrains downloader)
RUN dnf update -y && \
    dnf install -y --setopt=install_weak_deps=False \
        python3 \
        curl \
        tar && \
    dnf clean all

WORKDIR /root

# Environment variables for the downloader tool
ARG TOOL_NAME=jetbrains-clients-downloader-linux-x86_64-1867
ARG TOOL_URL="https://download.jetbrains.com/idea/code-with-me/backend/${TOOL_NAME}.tar.gz"
ARG OUTPUT_DIR=/root/jetbrains-server

# Copy the download script into the container
COPY download-jetbrains.sh /root/download-jetbrains.sh
RUN chmod +x /root/download-jetbrains.sh

# Download and extract the JetBrains downloader tool
RUN curl -L ${TOOL_URL} -o ${TOOL_NAME}.tar.gz && \
    tar -xf ${TOOL_NAME}.tar.gz && \
    rm -f ${TOOL_NAME}.tar.gz

# Build arguments (can be overridden at build time)
ARG INTELLIJ_BUILDS=243.26574.91,251.27812.49
ARG CLION_BUILDS=243.26574.92,251.27812.15
ARG PYCHARM_BUILDS=243.26574.90,251.26927.90

# Ensure output directory exists and run the download script
RUN mkdir -p ${OUTPUT_DIR} && \
    /root/download-jetbrains.sh \
        ${TOOL_NAME} \
        ${OUTPUT_DIR} \
        "${INTELLIJ_BUILDS}" \
        "${CLION_BUILDS}" \
        "${PYCHARM_BUILDS}"

# Optional: organize output folders (jbr and clients)
RUN mkdir -p ${OUTPUT_DIR}/{jbr,clients} && \
    mv ${OUTPUT_DIR}/jbr_* ${OUTPUT_DIR}/jbr 2>/dev/null || true && \
    mv ${OUTPUT_DIR}/JetBrainsClient* ${OUTPUT_DIR}/clients 2>/dev/null || true

