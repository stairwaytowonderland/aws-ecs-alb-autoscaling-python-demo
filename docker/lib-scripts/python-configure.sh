#!/bin/sh

# Only check for errors (set -e)
# Don't check for unset variables (set -u) since variables are set in Dockerfile
# Pipepail (set -o pipefail) is not available in sh
set -e

USE_PPA_IF_AVAILABLE="${USE_PPA_IF_AVAILABLE:-true}"
PYTHON_INSTALL_PATH="${PYTHON_INSTALL_PATH:-/usr/local/python}"
VERSION="${PYTHON_VERSION:-latest}"
INSTALL_PATH="${INSTALL_PATH:-"${PYTHON_INSTALL_PATH}/${PYTHON_VERSION}"}"
MAKE_LINKS="${MAKE_LINKS:-false}"
INSTALL_TOOLS="${INSTALL_TOOLS:-false}"

# shellcheck disable=SC1090
. "$INSTALL_HELPER"

updaterc() {
    case "$(cat "${2:-/etc/bash.bashrc}")" in
        *"$1"*) ;;
        *) printf '\n%s\n' "$1" >> "${2:-/etc/bash.bashrc}" ;;
    esac
}

get_major_minor_version() { echo "$1" | cut -d. -f1,2; }

get_alternatives_priority() {
    { update-alternatives --display "${1}${2-}" 2> /dev/null || echo "priority -1"; } | awk '/priority/ {print $NF}' | sort -n | head -n 1
}

make_links() {
    for py in python pip idle pydoc; do
        [ -e "${INSTALL_PATH}/bin/${py}" ] || ln -s "${INSTALL_PATH}/bin/${py}${major_version}" "${INSTALL_PATH}/bin/${py}"
    done
    [ -e "${INSTALL_PATH}/bin/python-config" ] || ln -s "${INSTALL_PATH}/bin/python${major_version}-config" "${INSTALL_PATH}/bin/python-config"
    ln -s "${PYTHON_INSTALL_PATH}/${PYTHON_VERSION}" "/usr/local/lib/python${major_minor_version}"
}

configure_python() {
    VERSION="$(cat "${INSTALL_PATH}/.manifest" | jq -r '.version')"
    major_version=$(get_major_version "$VERSION")
    major_minor_version=$(get_major_minor_version "$VERSION")

    SYSTEM_PYTHON="$(command -v "/usr/bin/python${major_version}" || true)"
    ALTERNATIVES_PATH="${ALTERNATIVES_PATH:-/usr/local/bin}"

    make_links

    updaterc "if [[ \"\${PATH}\" != *\"${INSTALL_PATH}/bin\"* ]]; then export \"PATH=${INSTALL_PATH}/bin:\${PATH}\"; fi"

    for py in python pip idle pydoc; do
        priority=$(($( get_alternatives_priority "$py" "$major_version") + 1))
        [ "$priority" -ge 0 ] || priority=$((priority + 1))
        syspy="$(readlink -f "${SYSTEM_PYTHON%/bin/python*}/bin/${py}${major_version}")"
        [ ! -x "$syspy" ] || update-alternatives --install "${ALTERNATIVES_PATH}/${py}${major_version}" "${py}${major_version}" "$syspy" "$priority" && priority="$((priority + 1))"
        {
            update-alternatives --install "${ALTERNATIVES_PATH}/${py}" "${py}" "${INSTALL_PATH}/bin/${py}" "$priority"
            update-alternatives --install "${ALTERNATIVES_PATH}/${py}${major_version}" "${py}${major_version}" "${INSTALL_PATH}/bin/${py}${major_version}" "$priority"
        } && priority="$((priority + 1))"
    done
    for py in python-config python${major_version}-config; do
        syspy="$(readlink -f "${SYSTEM_PYTHON%/bin/python*}/bin/${py}")"
        priority=$(($( get_alternatives_priority "$py") + 1))
        [ "$priority" -ge 0 ] || priority=$((priority + 1))
        [ ! -x "$syspy" ] || update-alternatives --install "${ALTERNATIVES_PATH}/${py}" "${py}" "$syspy" "$priority" && priority="$((priority + 1))"
        update-alternatives --install "${ALTERNATIVES_PATH}/${py}" "${py}" "${INSTALL_PATH}/bin/${py}" "$priority" && priority="$((priority + 1))"
    done
}

install_tools() {
    for tool in pipx poetry uv; do
        $PIP_INSTALL "$tool"
    done
}

main() {
    configure_python
    $PIP_INSTALL --upgrade pip
    [ "$INSTALL_TOOLS" != "true" ] || install_tools
}

main "$@"
