#!/usr/bin/env bash
set -Eeuo pipefail

export readonly LXQ_XEPH_MIN_DISPLAY_NUM="20"

readonly LXQ_XEPH_SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
export LXQ_XEPH_SCRIPT_DIR

readonly LXQ_XEPH_REPO_DIR=$(dirname "${LXQ_XEPH_SCRIPT_DIR}")
export LXQ_XEPH_REPO_DIR

