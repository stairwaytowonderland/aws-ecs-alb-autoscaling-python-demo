#!/bin/sh

# Only check for errors (set -e)
# Don't check for unset variables (set -u) since variables are set in Dockerfile
# Pipepail (set -o pipefail) is not available in sh
set -e

# shellcheck disable=SC1090
. "$INSTALL_HELPER"

install_clibssh() {
    LEVEL='*' $LOGGER "Preparing to install libssh-4..."

    cwd="$PWD"
    DOWNLOAD_DIR=/tmp/libssh
    git clone https://git.libssh.org/projects/libssh.git "$DOWNLOAD_DIR"
    if [ -d "$DOWNLOAD_DIR" ]; then
        mkdir -p "${DOWNLOAD_DIR}/build"
        cd "${DOWNLOAD_DIR}/build"
    else
        LEVEL='error' $LOGGER "Failed to download libssh."
        exit 1
    fi
    install_packages "${PACKAGE_DEPENDENCIES# }"
    cmake ..
    make
    make install
    cd "$cwd" && rm -rf "$DOWNLOAD_DIR"

    # Cleanup
    remove_packages "${PACKAGE_DEPENDENCIES# }"
}

LEVEL='ƒ' $LOGGER "Installing libssh..."

ESSENTIAL_PACKAGES="${ESSENTIAL_PACKAGES% } $(
    cat << EOF
build-essential
cmake
git
EOF
)"

PACKAGE_DEPENDENCIES="${PACKAGE_DEPENDENCIES% } $(
    cat << EOF
libssl-dev
zlib1g-dev
EOF
)"

install_libssh() {
    PACKAGE_CLEANUP="${PACKAGE_CLEANUP:-true}"

    for pkg in $ESSENTIAL_PACKAGES; do
        if ! dpkg -s "$pkg" > /dev/null 2>&1; then
            PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL% } $pkg"
        fi
    done

    update_and_install "${PACKAGES_TO_INSTALL# }"

    install_clibssh
}

main() {
    # remove_packages libssh-4
    install_libssh
    remove_packages "${PACKAGES_TO_INSTALL# }"
}

main "$@"
