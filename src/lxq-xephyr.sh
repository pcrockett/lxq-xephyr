#!/usr/bin/env bash
set -Eeuo pipefail
[[ "${BASH_VERSINFO[0]}" -lt 4 ]] && echo "Bash >= 4 required" && exit 1

if is_set "${LXQ_SHORT_SUMMARY+x}"; then
    printf "\t\tSet up templates to use Xephyr"
    exit 0
fi

readonly SCRIPT_DIR=$(dirname "$(readlink -f "${0}")")

# shellcheck source=/dev/null
. "${SCRIPT_DIR}/_util.sh"

function find_subcommand_scripts() {
    find "${LXQ_SCRIPT_DIR}" -maxdepth 1 -mindepth 1 -regex ".*/lxq-xephyr-[a-z]+\.sh"

    plugin_dirs=$(find -L "${LXQ_PLUGIN_DIR}" -maxdepth 1 -mindepth 1 -type d)
    for plugin_dir in $plugin_dirs
    do
        plugin_src_dir="${plugin_dir}/src"
        if [ -d "${plugin_src_dir}" ]; then
            find -L "${plugin_src_dir}" -maxdepth 1 -mindepth 1 -regex ".*/lxq-xephyr-[a-z]+\.sh"
        fi
    done
}

subcommand_scripts=$(find_subcommand_scripts)

declare -A subcommands
for script in $subcommand_scripts
do
    if [[ $script =~ /lxq-xephyr-([a-z]+)\.sh$ ]]; then
        subcom="${BASH_REMATCH[1]}"
        subcommands["${subcom}"]="${script}"
    else
        panic "$script did not match regex as expected."
    fi
done

function print_subcommand_summary() {
    full_script_path="${1}"
    if [[ $full_script_path =~ /lxq-xephyr-([a-z]+)\.sh$ ]]; then
        command_name="${BASH_REMATCH[1]}"
        summary=$(LXQ_SHORT_SUMMARY=1 "${full_script_path}")
        printf "  %s%s\n" "${command_name}" "${summary}" >&2
    else
        panic "${full_script_path} did not match regex as expected."
    fi
}

function show_usage() {
    printf "Usage: lxq xephyr [command]\n" >&2
    printf "\n" >&2
    printf "Available commands:\n" >&2

    for s in $subcommand_scripts
    do
        print_subcommand_summary "${s}"
    done

    printf "\n" >&2
    printf "Flags:\n">&2
    printf "  -h, --help\t\tShow help message then exit\n" >&2
}

function show_usage_and_exit() {
    show_usage
    exit 1
}

function parse_commandline() {

    if [ "${#}" -gt "0" ]; then
        if is_set "${subcommands[${1}]+x}"; then
            LXQ_COMMAND="${subcommands[${1}]}"
            return # Let subcommands parse the rest of the parameters
        fi
    fi

    while [ "${#}" -gt "0" ]; do
        local consume=1

        case "$1" in
            -h|-\?|--help)
                ARG_HELP="true"
            ;;
            *)
                echo "Unrecognized argument: ${1}"
                show_usage_and_exit
            ;;
        esac

        shift ${consume}
    done
}

parse_commandline "$@"

if is_set "${LXQ_COMMAND+x}"; then

    default_config="${LXQ_XEPH_REPO_DIR}/default-config.sh"
    user_config="${LXQ_XEPH_REPO_DIR}/user-config.sh"

    # shellcheck source=/dev/null
    . "${default_config}"

    if [ -f "${user_config}" ]; then
        # shellcheck source=/dev/null
        . "${user_config}"
    fi

    shift 1
    "${LXQ_COMMAND}" "$@"
    exit "${?}"
fi

if is_set "${ARG_HELP+x}"; then
    show_usage_and_exit
fi

echo "No arguments specified."
show_usage_and_exit
