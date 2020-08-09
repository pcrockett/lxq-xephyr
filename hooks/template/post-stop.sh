#!/usr/bin/env bash
set -Eeuo pipefail

is_set "${LXQ_TEMPLATE_NAME+x}" || panic "Expected LXQ_TEMPLATE_NAME environment variable."
stop_xephyr "${LXQ_TEMPLATE_NAME} template"
