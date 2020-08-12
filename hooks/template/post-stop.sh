#!/usr/bin/env bash
set -Eeuo pipefail

lxq_is_set "${LXQ_TEMPLATE_NAME+x}" || lxq_panic "Expected LXQ_TEMPLATE_NAME environment variable."
stop_xephyr "${LXQ_TEMPLATE_NAME} template"
