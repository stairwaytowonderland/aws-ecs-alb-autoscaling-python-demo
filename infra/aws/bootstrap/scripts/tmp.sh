#!/bin/sh

# e.g. token.actions.githubusercontent.com
HOST='<Server FQDN>'; \
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
