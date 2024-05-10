#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

MITMPROXY_PATH="/home/mitmproxy/.mitmproxy"

if [ -f "$MITMPROXY_PATH/mitmproxy-ca.pem" ]; then
  f="$MITMPROXY_PATH/mitmproxy-ca.pem"
else
  f="$MITMPROXY_PATH"
fi

uid=$(stat -c "%u" "$f")
gid=$(stat -c "%g" "$f")

if [[ "$1" = "mitmdump" || "$1" = "mitmproxy" || "$1" = "mitmweb" ]] && [ "$EUID" -eq 0 ]; then
  if [ -w "/etc/passwd" ]; then
    groupmod --non-unique --gid $gid mitmproxy
    usermod  --non-unique --uid $uid mitmproxy
    exec gosu mitmproxy "$@"
  else
    exec gosu "$uid:$gid" "$@"
  fi
else
  exec "$@"
fi
