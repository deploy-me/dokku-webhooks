#!/usr/bin/env bash
set -eo pipefail; [[ $DOKKU_TRACE ]] && set -x
source "$PLUGIN_CORE_AVAILABLE_PATH/common/functions"
source "$(dirname $0)/config"

ACTION=$1; APP=$2; shift; shift

join () {
  IFS=$1; shift; echo "$*"
}

dokku_log_info1 "Running webhooks for $ACTION $APP"

[[ -f "$HOOKS_FILE" ]] || exit 0

PAYLOAD=$(join '&' action=${ACTION} app=${APP} "$@")

while read URL; do
  if ! curl -sSL -X POST -d ${PAYLOAD} -o/dev/null ${URL}; then
      dokku_log_warn "Failed to post webhook to '$URL'. Continuing..."
  fi
done < "$HOOKS_FILE"
