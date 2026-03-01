#!/bin/sh

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

EC2_PRIVATE_KEY_PEM_FILE="${EC2_PRIVATE_KEY_PEM_FILE:-ec2-connect.pem}"
EC2_HOST=${1-}
EC2_USER="${2:-ec2-user}"

usage() {
  echo "Usage: $0 <ec2-host> [<ec2-user>]"
  return ${1:-0}
}

if [ -z "$EC2_HOST" ]; then
  usage 1 || exit 1
fi

main() {
  set -x

  ssh -i "${SCRIPT_DIR}/../$EC2_PRIVATE_KEY_PEM_FILE" "${EC2_USER}@${EC2_HOST}"
}

main "$@"
