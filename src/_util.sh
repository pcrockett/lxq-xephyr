#!/usr/bin/env bash
set -Eeuo pipefail

export readonly LXQ_XEPH_MIN_DISPLAY_NUM="20"

readonly LXQ_XEPH_SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
export LXQ_XEPH_SCRIPT_DIR

readonly LXQ_XEPH_REPO_DIR=$(dirname "${LXQ_XEPH_SCRIPT_DIR}")
export LXQ_XEPH_REPO_DIR

function find_unused_display_num() {
    xephyr_display="${LXQ_XEPH_MIN_DISPLAY_NUM}"
    while [ -e "/tmp/.X11-unix/X${xephyr_display}" ]; do
        xephyr_display=$((xephyr_display+1))
        if [ "$xephyr_display" -ge 256 ]; then # TODO: What is the max display number?
            panic "Unable to find unused display number."
        fi
    done

    echo xephyr_display
}

function generate_xeph_config() {

    is_set "${1+x}" || panic "Expecting Xephyr display number as parameter"
    ARG_DISPLAY_NUM="${1}"

    cat << EOF
# Xephyr config
lxc.mount.entry = /tmp/.X11-unix/X${ARG_DISPLAY_NUM} tmp/.X11-unix/X0 none bind,optional,create=file,ro
lxc.environment = DISPLAY=:0
EOF

}

function run_xephyr() {

    is_set "${1+x}" || panic "Expecting Xephyr display number as first parameter"
    ARG_DISPLAY_NUM="${1}"

    is_set "${2+x}" || panic "Expecting window title as second parameter"
    ARG_WINDOW_TITLE="${2}"

    Xephyr -br -ac -noreset -screen "${LXQ_XEPH_SCREEN_SIZE}" -title "${ARG_WINDOW_TITLE}" ":${ARG_DISPLAY_NUM}" &

    attempts=0
    while [ ! -e "/tmp/.X11-unix/X${ARG_DISPLAY_NUM}" ]; do
        attempts=$((attempts+1))
        if [ "$attempts" -gt 5 ]; then
            panic "Unable to open Xephyr display."
        fi
        sleep 1s
    done
}
