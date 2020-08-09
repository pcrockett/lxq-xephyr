#!/usr/bin/env bash
set -Eeuo pipefail

# To override any of these defaults, create a new script in this directory
# called "user-config.sh" and re-export the environment variables you want
# to override.

export LXQ_XEPH_SCREEN_SIZE="1200x800"
export LXQ_XEPH_CONF_FILE_NAME="50_xephyr.conf"
