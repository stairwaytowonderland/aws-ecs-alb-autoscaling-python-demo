#!/bin/sh

set -e

# Simple logger script

# Usage: [LEVEL=<level>] $LOGGER <message>
#
# Arguments:
#   message: Message to log
#
# Output:
#   Logs message with timestamp and log level (default: info)

LEVEL="${LEVEL:-info}"
QUIET="${QUIET:-false}"

__log() {
    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"
    template="[%s] [%s] %s"

    case "$LEVEL" in
        '*' | '√' | 'ƒ') ;;
        debug | info | warn | warning | error)
            LEVEL="$(echo "$LEVEL" | tr '[:lower:]' '[:upper:]')"
            ;;
        '**')
            LEVEL="INFO"
            template="[%s] [%s] ** %s"
            ;;
        '✓' | '✔')
            LEVEL="SUCCESS"
            template="[%s] [%s] ** %s"
            ;;
        '!' | '¡')
            LEVEL="WARNING"
            template="[%s] [%s] !! %s"
            ;;
        *) LEVEL="INFO" ;;
    esac

    # shellcheck disable=SC2059
    printf "${template}\n" "${timestamp}" "${LEVEL}" "$*" >&2
}

__logger() {
    if [ "$#" -lt 1 ]; then
        LEVEL=error __log "Usage: [LEVEL=<level>] $LOGGER <message>"
        exit 1
    fi
    # Log the message
    __log "$@"
}

[ "$QUIET" = "true" ] || __logger "$@"
