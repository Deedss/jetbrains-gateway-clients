#!/bin/bash
set -euxo pipefail

TOOL_DIR=$1
OUTPUT_DIR=$2
INTELLIJ_BUILDS=$3
CLION_BUILDS=$4
PYCHARM_BUILDS=$5

download_backends() {
    local builds=$1
    local product=$2

    IFS=',' read -ra build_array <<< "$builds"
    for build in "${build_array[@]}"; do
        echo "Downloading backend for $product build $build..."
        /root/${TOOL_DIR}/bin/jetbrains-clients-downloader \
            --download-backends \
            --platforms-filter linux-x64 \
            --build-filter "$build" \
            --products-filter "$product" \
            --verbose \
            "$OUTPUT_DIR"
    done
}

download_clients() {
    local builds=$1
    local product=$2

    IFS=',' read -ra build_array <<< "$builds"
    for build in "${build_array[@]}"; do
        echo "Downloading client for $product build $build..."
        /root/${TOOL_DIR}/bin/jetbrains-clients-downloader \
            --platforms-filter linux-x64 \
            --build-filter "$build" \
            --products-filter "$product" \
            --verbose \
            "$OUTPUT_DIR"
    done
}

mkdir -p "$OUTPUT_DIR"

# Download backends
download_backends "$INTELLIJ_BUILDS" IU
download_backends "$CLION_BUILDS" CL
download_backends "$PYCHARM_BUILDS" PY

# Download clients
download_clients "$INTELLIJ_BUILDS" IU
download_clients "$CLION_BUILDS" CL
download_clients "$PYCHARM_BUILDS" PY

echo "✅ All downloads complete."
