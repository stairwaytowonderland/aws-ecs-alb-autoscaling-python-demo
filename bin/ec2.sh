#!/bin/sh

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

REGION="${AWS_REGION:-us-east-2}"
export AWS_DEFAULT_REGION="${REGION:-$AWS_DEFAULT_REGION}"
export AWS_DEFAULT_PROFILE="${AWS_PROFILE:-$AWS_DEFAULT_PROFILE}"

ids() {
  set -x
  ids=$(terraform -chdir="${SCRIPT_DIR}/../infra/aws/app" output -json ephemeral_instance_ids 2>/dev/null | jq '.[]' --raw-output)
  [ -n "$ids" ] || return $?
}

describe_ec2() {
  if [ $# -gt 0 ]; then
    set -x
    aws ec2 describe-instances --profile "${AWS_DEFAULT_PROFILE}" --instance-ids $@ --region "${AWS_DEFAULT_REGION}" --query Reservations[].Instances[].PublicDnsName --output json | jq '.[]' --raw-output
  fi
}

ssh_example() {
  cat <<EOF
sh $(dirname $0)/ssh.sh $@
EOF
}

main() {
  _ids="$(ids)"
  if [ $? -eq 0 ]; then
    dns=$(describe_ec2 "$_ids")
  else
    dns=$(describe_ec2 "$@")
  fi

  for d in $dns; do ssh_example $d; done
}

main "$@"
