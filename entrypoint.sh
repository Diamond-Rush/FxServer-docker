#!/bin/bash

##
# FXServer Pterodactyl Entrypoint
#
# Environment variables:
#   FXSERVER_VERSION  - Required. The FXServer build version string.
#                       Format: {build_number}-{commit_hash}
#                       Example: 25770-8ddccd4e4dfd6a760ce18651656463f961cc4761
#                       Find versions at: https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/
#
#   STARTUP           - Required (set by Pterodactyl). The command to start the server.
#
#   FXSERVER_TYPE     - Optional. "fivem" (default) or "redm".
##

set -e

# --- Configuration ---
SERVER_DIR="${HOME}"
ARTIFACT_DIR="${SERVER_DIR}/alpine"
FXSERVER_TYPE="${FXSERVER_TYPE:-fivem}"

# Map type to artifact URL path
case "${FXSERVER_TYPE}" in
    redm)
        ARTIFACT_BASE_URL="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master"
        ;;
    fivem|*)
        ARTIFACT_BASE_URL="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master"
        ;;
esac

# --- Artifact Download ---
if [ -z "${FXSERVER_VERSION}" ]; then
    echo "ERROR: FXSERVER_VERSION is not set."
    echo "Please set it to a valid build version string."
    echo "Example: 25770-8ddccd4e4dfd6a760ce18651656463f961cc4761"
    echo "Browse versions: ${ARTIFACT_BASE_URL}/"
    exit 1
fi

DOWNLOAD_URL="${ARTIFACT_BASE_URL}/${FXSERVER_VERSION}/fx.tar.xz"
VERSION_FILE="${SERVER_DIR}/.fxserver_version"

# Check if we already have this version installed
if [ -f "${VERSION_FILE}" ] && [ "$(cat "${VERSION_FILE}")" = "${FXSERVER_VERSION}" ] && [ -d "${ARTIFACT_DIR}" ]; then
    echo "FXServer version ${FXSERVER_VERSION} is already installed. Skipping download."
else
    echo "============================================="
    echo " Downloading FXServer artifacts"
    echo " Type:    ${FXSERVER_TYPE}"
    echo " Version: ${FXSERVER_VERSION}"
    echo " URL:     ${DOWNLOAD_URL}"
    echo "============================================="

    # Clean up any previous installation
    rm -rf "${ARTIFACT_DIR}" "${SERVER_DIR}/fx.tar.xz"

    # Download and extract
    if ! curl -fsSL "${DOWNLOAD_URL}" -o "${SERVER_DIR}/fx.tar.xz"; then
        echo "ERROR: Failed to download FXServer artifacts."
        echo "Please verify your FXSERVER_VERSION is correct."
        echo "Browse available versions: ${ARTIFACT_BASE_URL}/"
        exit 1
    fi

    tar xf "${SERVER_DIR}/fx.tar.xz" -C "${SERVER_DIR}"
    rm -f "${SERVER_DIR}/fx.tar.xz"

    # Record the installed version
    echo "${FXSERVER_VERSION}" > "${VERSION_FILE}"

    echo "FXServer artifacts installed successfully."
fi

# --- Start Server ---
if [ -z "${STARTUP}" ]; then
    echo "ERROR: STARTUP command is not set."
    echo "This container is designed to run with Pterodactyl Panel."
    echo "The STARTUP variable should be set automatically by the panel."
    exit 1
fi

# Replace Pterodactyl template variables ({{VAR}}) with environment values
MODIFIED_STARTUP=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

echo "============================================="
echo " Starting FXServer"
echo " Command: ${MODIFIED_STARTUP}"
echo "============================================="

# Execute the startup command
eval "${MODIFIED_STARTUP}"
