#!/bin/sh

VERSION="${VERSION:-latest}"

export DEBIAN_FRONTEND=noninteractive
export GITHUB_API_HEADER_ACCEPT="Accept: application/vnd.github.v3+json"
export API_TOKEN="${API_TOKEN-}"

__get_platform() {
    PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]') $(dpkg --print-architecture)"
    echo "$PLATFORM"
}

__get_os() {
    _platform="${1:-$(__get_platform)}"
    _platform_os="${_platform%% *}"
    case "$_platform_os" in
        linux)
            _download_os=linux
            ;;
        darwin)
            _download_os=darwin
            ;;
        *)
            LEVEL=error $LOGGER "Unsupported OS: $_platform_os"
            return 1
            ;;
    esac

    echo "$_download_os"
}

__get_arch() {
    _platform="${1:-$(__get_platform)}"
    _platform_arch="${_platform##* }"
    case "$_platform_arch" in
        x86_64 | amd64)
            _download_arch=amd64
            ;;
        aarch64 | armv8* | arm64)
            _download_arch=arm64
            ;;
        aarch32 | armv7* | armvhf*)
            _download_arch=arm
            ;;
        i?86) _download_arch=386 ;;
        *)
            LEVEL=error $LOGGER "Unsupported architecture: $_platform_arch"
            return 1
            ;;
    esac

    echo "$_download_arch"
}

get_major_version() { echo "$1" | cut -d. -f1; }
get_minor_version() { echo "$1" | cut -d. -f2; }
get_patch_version() { echo "$1" | cut -d. -f3; }
get_major_minor_version() { echo "$1" | cut -d. -f1,2; }

ensure_root() {
    if [ "$(id -u)" -ne 0 ]; then
        LEVEL='error' $LOGGER '(!)' "This script must be run as root. Current user ID: $(id -u)"
        return 1
    fi
}

install_packages() {
    # shellcheck disable=SC2086
    LEVEL='ƒ' $LOGGER "Installing the following packages: "$*
    # shellcheck disable=SC2086,SC2048
    apt-get -y install --no-install-recommends $*
}

update_and_install() {
    apt-get update
    install_packages "$@"
}

remove_packages() {
    PACKAGE_CLEANUP="${PACKAGE_CLEANUP:-true}"
    REMOVE_ONLY="${REMOVE_ONLY:-false}"
    if [ "$PACKAGE_CLEANUP" != "true" ] && [ "$REMOVE_ONLY" != "true" ]; then
        LEVEL='warn' $LOGGER "Cleanup is disabled. Skipping package removal: ""$*"
        return
    fi
    # shellcheck disable=SC2086
    LEVEL='ƒ' $LOGGER "Removing the following packages: "$*
    # shellcheck disable=SC2086,SC2048
    apt-get -y remove $*
    if [ "$REMOVE_ONLY" != "true" ]; then
        LEVEL='ƒ' $LOGGER "Autoremoving packages..."
        apt-get -y autoremove
    fi
}

# Usage example for defining packages to install:
#
# PACKAGES_TO_INSTALL="${PACKAGES_TO_INSTALL% } $(
#     cat << EOF
# list
# of
# packages
# EOF
# )"
#
# [ -z "$PACKAGES_TO_INSTALL" ] \
#     && update_and_install "$PACKAGES_TO_INSTALL" \
#     || echo "Warning: No packages to install."

__check_semver() {
    _version="${1-}"

    [ "$(echo "${_version}" | grep -o '\.' | wc -l)" = "2" ] && echo "$_version" >&2 || return 1
}

# __get_semver() {
#     _version="${1-}"

#     __check_semver "$_version" > /dev/null 2>&1 \
#         && echo "$_version" 2> /dev/null 2>&1 \
#         || return $?
# }

# GITHUB_TOKEN="YOUR_GITHUB_PAT"
# AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
# Use `git ls-remote --tags` for public repositories to avoid hitting API rate limits, and fallback to API if needed or if authentication is required.
# (see `find_version_from_git_tags`, below)
__rest_call() {
    if [ -n "$API_TOKEN" ]; then
        curl -fsSL --include "$1" -H "${GITHUB_API_HEADER_ACCEPT}" -H "Authorization: token ${API_TOKEN}"
    else
        curl -fsSL --include "$1" -H "${GITHUB_API_HEADER_ACCEPT}"
    fi
}

__rest_github_tags_paged() {
    URL="https://api.github.com/repos/${1}/tags?per_page=100"

    page=0
    max_pages="${2:-10}"  # safety to prevent long running loops
    type __rest_call > /dev/null 2>&1 || return 1
    while [ ! -z "$URL" ] && [ $page -lt "$max_pages" ]; do
        response=$(__rest_call "$URL")
        body=$(echo "$response" | sed -E '1,/^\r?$/d')
        tags=$(echo "$body" | grep -oP '"name":\s*"v?\K[0-9]+\.[0-9]+\.[0-9]+"' | tr -d '"' | sort -ruV)

        echo "$tags"

        # Extract the 'Link' header for the next page URL
        # https://docs.github.com/en/rest/using-the-rest-api/using-pagination-in-the-rest-api?apiVersion=2022-11-28
        next_url=$(echo "$response" | grep -F 'link: <' | sed -e 's/link: <\([^>]*\)>.*rel="next".*/\1/' -e 't' -e 'd')

        URL="$next_url"
        page=$((page + 1))
    done | sort -ruV

    unset URL response body tags next_url
}

# https://github.com/devcontainers/features/blob/main/src/python/install.sh
__find_version_from_git_tags() {
    repository=$1
    requested_version=${2:-latest}
    [ "${requested_version}" != "none" ] || return
    url="https://github.com/${repository}"
    prefix=${3:-"tags/v"}
    separator=${4:-"."}
    last_part_optional=${5:-"false"}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        # escaped_separator=${separator//./\\.}
        escaped_separator=$(printf '%s\n' "$separator" | sed "s/[][\.*^$(){}?+|/]/\\\&/g")
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        regex="$(echo "$prefix" | sed 's|\/|\\/|g')\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        version_list="$(git ls-remote --tags "${url}" | grep -oP "${regex}" | tr -d "$prefix" | tr "${separator}" "." | sort -ruV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            VERSION="$(echo "${version_list}" | head -n 1)"
        else
            VERSION="$(echo "${version_list}" | grep -E -m 1 "^$(printf '%s' "$requested_version" | sed "s/[.[\*^$(){}?+|/]/\\\&/g")([\\.\\s]|$)")"
        fi
    fi
}

__get_version_with_rest_api() {
    _github_repo="${1-}"
    _version="${2:-latest}"

    if [ -z "$_github_repo" ]; then
        LEVEL='error' $LOGGER "GitHub repository is required to fetch version (${_version}) from tags."
        return 1
    fi

    if ! __check_semver > /dev/null 2>&1 "$_version"; then
        # https://github.com/devcontainers/features/blob/main/src/git/install.sh#L291C76-L291C117
        # version_list="$(curl -sSL -H "Accept: application/vnd.github.v3+json" "https://api.github.com/repos/${_github_repo}/tags" | grep -oP '"name":\s*"v\K[0-9]+\.[0-9]+\.[0-9]+"' | tr -d '"' | sort -rV)"
        version_list="$(__rest_github_tags_paged "$_github_repo")"
        if [ "${_version}" = "latest" ] || [ "${_version}" = "lts" ] || [ "${_version}" = "current" ]; then
            VERSION="$(echo "${version_list}" | head -n 1)"
        else
            escaped_version="$(echo "${_version}" | sed 's/\./\\./g')"
            VERSION="$(echo "${version_list}" | grep -E -m 1 "^${escaped_version}([\\.\\s]|$)")"
        fi
        escaped_version_check="$(echo "${VERSION}" | sed 's/\./\\./g')"
        if [ -z "${VERSION}" ] || ! echo "${version_list}" | grep "^${escaped_version_check}$" > /dev/null 2>&1; then
            LEVEL='error' $LOGGER "Invalid git version: ${VERSION}"
            return 2
        fi
    fi

    # shellcheck disable=SC2015
    __check_semver > /dev/null 2>&1 "$VERSION" && echo "$VERSION" || {
        LEVEL='error' $LOGGER "Version must be a semantic version (e.g., 1.2.3): ${VERSION}"
        return 3
    }
}

__set_url_parts() {
    _github_repo="${1-}"
    _version="${2-}"

    if [ $# -gt 3 ]; then
        _version_prefix="${3-}"
        _url_prefix="${4%"$_version_prefix"}"
        DOWNLOAD_URL_PREFIX="${_url_prefix%/}"
    else
        _url_prefix="${3-}"
        _version_prefix=""
        DOWNLOAD_URL_PREFIX="${_url_prefix}"
    fi

    # ? swap for __find_version_from_git_tags?
    _download_version="$(__get_version_with_rest_api "$_github_repo" "$_version")" || return $?
    DOWNLOAD_VERSION="${_version_prefix}${_download_version#"$_version_prefix"}"
    DOWNLOAD_PLATFORM="$(uname -sm | tr '[:upper:]' '[:lower:]')"
    DOWNLOAD_OS="$(__get_os "$DOWNLOAD_PLATFORM")" || return $?
    DOWNLOAD_ARCH="$(__get_arch "$DOWNLOAD_PLATFORM")" || return $?
}

__install_from_tarball() {
    DOWNLOAD_URL="${1-}"
    INSTALL_PREFIX="${2-"/usr/local"}"
    file_ext="${DOWNLOAD_URL##*.}"
    case "$file_ext" in
        gz | tgz)
            tar_opts="z"
            ;;
        xz)
            tar_opts="J"
            ;;
        bz2 | bz)
            tar_opts="j"
            ;;
        *)
            LEVEL='error' $LOGGER "Unsupported tarball extension: $file_ext"
            return 1
            ;;
    esac

    mkdir -p "$INSTALL_PREFIX"
    LEVEL='*' $LOGGER "Downloading from $DOWNLOAD_URL ..."
    (
        set -x
        curl -fsSL "$DOWNLOAD_URL" | tar -C "$INSTALL_PREFIX" -"xv${tar_opts}f" -
    )
}

__install_from_package() {
    DOWNLOAD_URL="${1-}"
    file_ext="${DOWNLOAD_URL##*.}"
    [ "$file_ext" = "deb" ] || {
        LEVEL='error' $LOGGER "Unsupported package extension: $file_ext"
        return 1
    }

    LEVEL='*' $LOGGER "Downloading from $DOWNLOAD_URL ..."
    (
        set -x
        curl -fsOSL "$DOWNLOAD_URL" \
            && dpkg -i "${DOWNLOAD_URL##*/}" \
            && rm -f "${DOWNLOAD_URL##*/}"
    )
}

export DOWNLOAD_VERSION DOWNLOAD_PLATFORM DOWNLOAD_OS DOWNLOAD_ARCH DOWNLOAD_URL_PREFIX

# Usage example for downloading and installing from a tarball:
#
# # Include install-helper.sh
# . install-helper.sh
#
# main() {
#     if __set_url_parts "owner/repo" "$VERSION"; then
#         build_url() {
#             url_prefix="https://github.com/owner/repo/releases/download/v"
#             echo "${url_prefix}${DOWNLOAD_VERSION}/file-name-${DOWNLOAD_VERSION}-${DOWNLOAD_OS}-${DOWNLOAD_ARCH}.tar.gz"
#         }
#         DOWNLOAD_URL="$(build_url)"
#     else
#         $LOGGER "Failed to determine download parameters for owner/repo version $VERSION"
#         exit 1
#     fi
#     __install_from_tarball "$DOWNLOAD_URL"
# }
