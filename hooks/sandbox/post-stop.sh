#!/usr/bin/env bash
set -Eeuo pipefail

is_set "${LXQ_SANDBOX_NAME+x}" || panic "Expected LXQ_SANDBOX_NAME environment variable."
stop_xephyr "${LXQ_SANDBOX_NAME} sandbox"
