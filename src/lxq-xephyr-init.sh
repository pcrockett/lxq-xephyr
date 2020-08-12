#!/usr/bin/env bash
set -Eeuo pipefail

if lxq_is_set "${LXQ_SHORT_SUMMARY+x}"; then
    printf "\t\t\tSet up Xephyr for a template"
    exit 0
fi

readonly GUI_CONFIG_DIR="${LXQ_XEPH_REPO_DIR}/templates"

function show_usage() {
    printf "Usage: lxq xephyr init [template-name]\n" >&2
    printf "\n" >&2
    printf "Flags:\n">&2
    printf "  -h, --help\t\tShow help message then exit\n" >&2
}

function show_usage_and_exit() {
    show_usage
    exit 1
}

function parse_commandline() {

    while [ "${#}" -gt "0" ]; do
        local consume=1

        case "$1" in
            -h|-\?|--help)
                ARG_HELP="true"
            ;;
            *)
                if lxq_is_set "${ARG_TEMPLATE_NAME+x}"; then
                    echo "Unrecognized argument: ${1}"
                    show_usage_and_exit
                else
                    ARG_TEMPLATE_NAME="${1}"
                fi
            ;;
        esac

        shift ${consume}
    done
}

parse_commandline "$@"

if lxq_is_set "${ARG_HELP+x}"; then
    show_usage_and_exit
fi

lxq_is_set "${ARG_TEMPLATE_NAME+x}" || lxq_panic "No template name specified."

template_config_dir="${LXQ_REPO_DIR}/templates/${ARG_TEMPLATE_NAME}/config.d"
test -d "${template_config_dir}" || lxq_panic "Template \"${ARG_TEMPLATE_NAME}\" does not exist."

xephyr_config="${template_config_dir}/${LXQ_XEPH_CONF_FILE_NAME}"
test ! -f "${xephyr_config}" || lxq_panic "Template \"${ARG_TEMPLATE_NAME}\" has already been initialized."

# Just need to create the file to mark it as a xephyr template
touch "${xephyr_config}"
