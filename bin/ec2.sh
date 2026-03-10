#!/bin/sh

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

REGION="${AWS_REGION:-us-east-2}"
export AWS_REGION="${REGION:-$AWS_DEFAULT_REGION}"
export AWS_PROFILE="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"

ids() {
  terraform -chdir="${SCRIPT_DIR}/../infra/aws/app" output -json ephemeral_instance_ids 2>/dev/null | jq '.[]' --raw-output || return $?
}

describe_ec2() {
  if [ $# -gt 0 ]; then
    aws ec2 describe-instances --profile "${AWS_PROFILE}" --instance-ids "$@" --region "${AWS_REGION}" --query Reservations[].Instances[].PublicDnsName --output json | jq '.[]' --raw-output
  fi
}

ssh_example() {
  cat <<EOF
sh $(dirname "$0")/ssh.sh $@
EOF
}

main() {
  (set -x ; describe_ec2 $(ids)) | while read -r dns; do ssh_example "$dns"; done
}

main "$@"
