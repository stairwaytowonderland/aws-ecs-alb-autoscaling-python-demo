#!/bin/sh

##############################################
# Single line POSIX (mostly) command to obtain
# OIDC provider thumbprints from a secure host.
##############################################
# Pre-requisites: jq, wget, openssl, sed, awk, tr
##############################################


### Download (stdout) and execute (pipe to bash)
# GIST_ID='<Gist ID>'; \
# wget -qO- https://api.github.com/users/andrewhaller/gists \
#   | jq --arg gist "$GIST_ID" --arg file "${GIST_FILE:-thumbprints.sh}" '.[]
#     | select(.id == $gist)
#     | .files[]
#     | select(.filename == $file)
#     | .raw_url' -r \
#   | wget -qO- -i - \
#   | sh -


### First cert (server cert) only
# openssl s_client \
#   -servername token.actions.githubusercontent.com \
#   -showcerts \
#   -connect token.actions.githubusercontent.com:443 \
#   < /dev/null 2>/dev/null \
#   | openssl x509 -fingerprint -sha1 -noout \
#   | awk -F'=' '{print $2}' \
#   | sed 's/://g' \
#   | tr '[:upper:]' '[:lower:]'


### All certs (server, intermediate, root)
### For full POSIX compliance, hardcode the <HOST> (wget and jq steps omitted)
OPENID_CONFIG_URL=$(printf 'https://%s/%s' \
  'vstoken.actions.githubusercontent.com' \
  '.well-known/openid-configuration'); \
HOST=$(wget -qO- "$OPENID_CONFIG_URL" \
    | jq -r '.jwks_uri | split("/")[2]'); \
PORT='443'; \
openssl s_client \
  -servername "$HOST" \
  -showcerts \
  -connect "$HOST:$PORT" \
  < /dev/null 2>/dev/null \
  | awk '/BEGIN/,/END/{ if(/BEGIN/){a++}; print}' \
  | {
    cert_text=""
    while IFS= read -r line; do
      case "$line" in
        *"END CERTIFICATE"*)
          cert_text="$cert_text$line
"
          printf '%s' "$cert_text" \
            | openssl x509 \
              -fingerprint \
              -sha1 \
              -noout
          cert_text=""
          ;;
        *)
          cert_text="$cert_text$line
"
          ;;
      esac
    done
    } \
  | awk -F'=' '{print $2}' \
  | sed 's/://g' \
  | tr '[:upper:]' '[:lower:]'
