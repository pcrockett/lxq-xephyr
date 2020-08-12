#!/usr/bin/env bash
set -Eeuo pipefail

lxq_is_set "${LXQ_SANDBOX_NAME+x}" || lxq_panic "Expected LXQ_SANDBOX_NAME environment variable."
stop_xephyr "${LXQ_SANDBOX_NAME} sandbox"
