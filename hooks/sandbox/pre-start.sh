#!/usr/bin/env bash
set -Eeuo pipefail

readonly DEPENDENCIES=(Xephyr)
readonly SCRIPT_NAME=$(basename "${0}")

for dep in "${DEPENDENCIES[@]}"; do
    installed "${dep}" || panic "Missing '${dep}'"
done

function show_usage() {
    printf "Usage: %s\n" "${SCRIPT_NAME}" >&2
    printf "Expected environment variables:\n"
    printf "  LXQ_SANDBOX_NAME\n"
    printf "  LXQ_TEMPLATE_NAME\n"
}

function show_usage_and_exit() {
    show_usage
    exit 1
}

is_set "${LXQ_SANDBOX_NAME+x}" || panic "Expected LXQ_SANDBOX_NAME environment variable."
is_set "${LXQ_TEMPLATE_NAME+x}" || panic "Expected LXQ_TEMPLATE_NAME environment variable."

sandbox_config_file="${LXQ_REPO_DIR}/sandboxes/${LXQ_SANDBOX_NAME}/config.d/${LXQ_XEPH_CONF_FILE_NAME}"
template_config_file="${LXQ_REPO_DIR}/templates/${LXQ_TEMPLATE_NAME}/config.d/${LXQ_XEPH_CONF_FILE_NAME}"
if [ ! -f "${sandbox_config_file}" ] && [ ! -f "${template_config_file}" ]; then
    exit 0 # This sandbox was not intended to have a GUI
fi

xephyr_display=$(find_unused_display_num)
generate_xeph_config "${xephyr_display}" > "${sandbox_config_file}"
run_xephyr "${xephyr_display}" "${LXQ_SANDBOX_NAME} sandbox"
