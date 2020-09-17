#!/usr/bin/env bash
set -Eeuo pipefail

LXQ_XEPH_SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")
export LXQ_XEPH_SCRIPT_DIR

LXQ_XEPH_REPO_DIR=$(dirname "${LXQ_XEPH_SCRIPT_DIR}")
export LXQ_XEPH_REPO_DIR

LXQ_XEPH_RUN_DIR="/run/user/$UID/lxq/plugin/xephyr"
export LXQ_XEPH_RUN_DIR

function find_unused_display_num() {
    xephyr_display="20"
    while [ -e "/tmp/.X11-unix/X${xephyr_display}" ]; do
        xephyr_display=$((xephyr_display+1))
        if [ "$xephyr_display" -ge 256 ]; then # TODO: What is the max display number?
            lxq_panic "Unable to find unused display number."
        fi
    done

    echo "${xephyr_display}"
}
export -f find_unused_display_num

function generate_xeph_config() {

    lxq_is_set "${1+x}" || lxq_panic "Expecting Xephyr display number as parameter"
    ARG_DISPLAY_NUM="${1}"

    cat << EOF
# Xephyr config
lxc.mount.entry = tmpfs tmp tmpfs defaults # See https://github.com/lxc/lxc/issues/434
lxc.mount.entry = /tmp/.X11-unix/X${ARG_DISPLAY_NUM} tmp/.X11-unix/X0 none bind,optional,create=file,ro
lxc.environment = DISPLAY=:0
EOF
}
export -f generate_xeph_config

function run_xephyr() {

    lxq_is_set "${1+x}" || lxq_panic "Expecting Xephyr display number as first parameter"
    ARG_DISPLAY_NUM="${1}"

    lxq_is_set "${2+x}" || lxq_panic "Expecting window title as second parameter"
    ARG_WINDOW_TITLE="${2}"

    Xephyr -br -ac -noreset -screen "${LXQ_XEPH_SCREEN_SIZE}" -title "${ARG_WINDOW_TITLE}" ":${ARG_DISPLAY_NUM}" &

    xeph_pid="${!}"
    xeph_run_dir="${LXQ_XEPH_RUN_DIR}/${ARG_WINDOW_TITLE}"
    test -d "${xeph_run_dir}" || mkdir --parent "${xeph_run_dir}"
    echo "${xeph_pid}" > "${xeph_run_dir}/pid"

    attempts=0
    while [ ! -e "/tmp/.X11-unix/X${ARG_DISPLAY_NUM}" ]; do
        attempts=$((attempts+1))
        if [ "$attempts" -gt 5 ]; then
            lxq_panic "Unable to open Xephyr display."
        fi
        sleep 1s
    done
}
export -f run_xephyr

function stop_xephyr() {
    lxq_is_set "${1+x}" || lxq_panic "Expecting window title as only parameter"
    ARG_WINDOW_TITLE="${1}"

    xeph_run_dir="${LXQ_XEPH_RUN_DIR}/${ARG_WINDOW_TITLE}"
    test -d "${xeph_run_dir}" || return 0 # Xephyr wasn't running in the first place; common for non-gui containers

    original_pid=$(cat "${xeph_run_dir}/pid")
    kill "${original_pid}"

    rm --recursive -- "${xeph_run_dir}"
}
export -f stop_xephyr
