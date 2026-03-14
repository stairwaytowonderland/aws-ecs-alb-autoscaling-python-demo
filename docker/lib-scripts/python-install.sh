#!/bin/sh

# Only check for errors (set -e)
# Don't check for unset variables (set -u) since variables are set in Dockerfile
# Pipepail (set -o pipefail) is not available in sh
set -e

PYTHON_INSTALL_PATH="${PYTHON_INSTALL_PATH:-/usr/local/python}"
VERSION="${PYTHON_VERSION:-latest}"
INSTALL_PATH="${INSTALL_PATH:-"${PYTHON_INSTALL_PATH}/${PYTHON_VERSION}"}"

# shellcheck disable=SC1090
. "$INSTALL_HELPER"

updaterc() {
    case "$(cat "${2:-/etc/bash.bashrc}")" in
        *"$1"*) ;;
        *) printf '\n%s\n' "$1" >> "${2:-/etc/bash.bashrc}" ;;
    esac
}

get_major_minor_version() { echo "$1" | cut -d. -f1,2; }

download_cpython_version() {
    LEVEL='*' $LOGGER "Downloading Python version ${1}..."

    cd /tmp
    cpython_download_prefix="Python-${1}"
    if type xz > /dev/null 2>&1; then
        cpython_download_filename="${cpython_download_prefix}.tar.xz"
    elif type gzip > /dev/null 2>&1; then
        cpython_download_filename="${cpython_download_prefix}.tgz"
    else
        LEVEL='error' $LOGGER "Required package (xz-utils or gzip) not found."
        return 1
    fi

    DOWNLOAD_URL="https://www.python.org/ftp/python/${1}/${cpython_download_filename}"

    __install_from_tarball "$DOWNLOAD_URL" "$PWD" && DOWNLOAD_DIR="${PWD}/${cpython_download_prefix}"
}

install_cpython() {
    LEVEL='*' $LOGGER "Preparing to install Python version ${VERSION} ($PYTHON_VERSION) to ${INSTALL_PATH}..."

    # Check if the specified Python version is already installed
    if [ -d "$INSTALL_PATH" ]; then
        LEVEL='!' $LOGGER "Requested Python version ${VERSION} already installed at ${INSTALL_PATH}."
    else
        cwd="$PWD"
        mkdir -p "$INSTALL_PATH"
        download_cpython_version "${VERSION}"
        if [ -d "$DOWNLOAD_DIR" ]; then
            cd "$DOWNLOAD_DIR"
        else
            LEVEL='error' $LOGGER "Failed to download Python version ${VERSION}."
            exit 1
        fi
        install_packages "${PYTHON_BUILD_DEPENDENCIES# }"
        ./configure --prefix="$INSTALL_PATH" --with-ensurepip=install --enable-optimizations
        make -j 8
        make install
        cd "$cwd" && rm -rf "$DOWNLOAD_DIR"

        # Cleanup
        remove_packages "${PYTHON_BUILD_DEPENDENCIES# }"

        # Strip unnecessary files to reduce image size
        if [ "$BUILD_CLEANUP" = "true" ]; then
            find "$INSTALL_PATH" -type d -name 'test' -exec rm -rf {} + 2> /dev/null || true
            find "$INSTALL_PATH" -type d -name '__pycache__' -exec rm -rf {} + 2> /dev/null || true
            find "$INSTALL_PATH" -name '*.pyc' -delete
            find "$INSTALL_PATH" -name '*.pyo' -delete
            rm -rf "$INSTALL_PATH"/lib/python*/config-*
            rm -rf "$INSTALL_PATH"/lib/*.a
        fi
    fi
}

LEVEL='ƒ' $LOGGER "Installing Python utilities..."

ESSENTIAL_PACKAGES="${ESSENTIAL_PACKAGES% } $(
    cat << EOF
build-essential
ca-certificates
curl
gcc
git
jq
make
tar
xz-utils
EOF
)"

PYTHON_BUILD_DEPENDENCIES="${PYTHON_BUILD_DEPENDENCIES% } $(
    cat << EOF
libbz2-dev
libffi-dev
libgdbm-dev
liblzma-dev
libncurses5-dev
libreadline-dev
libssl-dev
libsqlite3-dev
libxml2-dev
libxmlsec1-dev
pkg-config
tk-dev
EOF
)"

install_python() {
    PACKAGE_CLEANUP="${PACKAGE_CLEANUP:-true}"
    BUILD_CLEANUP="${BUILD_CLEANUP:-true}"

    for pkg in $ESSENTIAL_PACKAGES; do
        if ! dpkg -s "$pkg" > /dev/null 2>&1; then
            PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL% } $pkg"
        fi
    done

    update_and_install "${PACKAGES_TO_INSTALL# }"

    __find_version_from_git_tags "python/cpython" "${VERSION}" "tags/v" "."

    # major_version="${VERSION%%.*}"
    # major_minor_version="${VERSION%.*}"
    major_version=$(get_major_version "$VERSION")
    major_minor_version=$(get_major_minor_version "$VERSION")

    install_cpython "$VERSION"

    updaterc "if [[ \"\${PATH}\" != *\"${INSTALL_PATH}/bin\"* ]]; then export \"PATH=${INSTALL_PATH}/bin:\${PATH}\"; fi"
    updaterc "PYTHON_VERSION=${VERSION}"
    {
        echo "PYTHON_VERSION=${VERSION}"
        echo "PYTHON_INSTALL_PATH=${INSTALL_PATH}"
        echo "PATH=${INSTALL_PATH}/bin:${PATH}"
    } >> /etc/environment

    PYTHON_SRC_ACTUAL="${INSTALL_PATH}/bin/python${major_minor_version}"
    PATH="${INSTALL_PATH}/bin:${PATH}"

    cat >> "${INSTALL_PATH}/.manifest" << EOF
{"path":"${PYTHON_SRC_ACTUAL}","url":"${DOWNLOAD_URL}","version":"${VERSION}","major_version":"${major_version}","major_minor_version":"${major_minor_version}"}
EOF
}

main() {
    install_python
    remove_packages "${PACKAGES_TO_INSTALL# }"
}

main "$@"
