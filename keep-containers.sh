#!/usr/bin/env bash

# Enforce strict error handling
set -euo pipefail

# --- Constants & Variables ---
readonly SCRIPT_NAME="${0##*/}"
readonly DEFAULT_KEEP_COUNT=2

# --- Helper Functions ---

log_info() {
    echo -e "[INFO] $*"
}

log_error() {
    echo -e "[ERROR] $*" >&2
}

usage() {
    echo "Usage: ${SCRIPT_NAME} -p <prefix> -r <runtime> [-k <keep_count>] [-h]"
    echo ""
    echo "Options:"
    echo "  -p  Prefix of the container name to filter by (Required)"
    echo "  -r  Container runtime CLI to use: 'docker' or 'podman' (Required)"
    echo "  -k  Number of recent containers to keep (Default: ${DEFAULT_KEEP_COUNT})"
    echo "  -h  Show this help message"
}

cleanup_containers() {
    local prefix="$1"
    local keep_count="$2"
    local cli="$3"

    log_info "Using container runtime: '${cli}'"

    # Fetch container IDs sorted by creation date (newest first).
    local -a containers
    mapfile -t containers < <("${cli}" ps -a -q --filter "name=^${prefix}")

    local total_containers="${#containers[@]}"
    log_info "Found ${total_containers} container(s) matching prefix '${prefix}'."

    if (( total_containers <= keep_count )); then
        log_info "Only ${total_containers} container(s) exist. Within the limit of ${keep_count}. No action required."
        return 0
    fi

    # Slice the array to isolate the older containers that need removal
    local containers_to_remove=("${containers[@]:keep_count}")
    local remove_count="${#containers_to_remove[@]}"

    log_info "Targeting ${remove_count} older container(s) for cleanup..."

    for container_id in "${containers_to_remove[@]}"; do
        log_info "Stopping container: ${container_id}..."
        # Ignore errors if the container is already exited/stopped
        "${cli}" stop "${container_id}" >/dev/null 2>&1 || true

        log_info "Removing container: ${container_id}..."
        # Force remove the container
        "${cli}" rm -f "${container_id}" >/dev/null
        
        log_info "Container ${container_id} successfully removed."
    done

    log_info "Cleanup completed successfully."
}

# --- Main Execution ---

main() {
    local prefix=""
    local runtime=""
    local keep_count="${DEFAULT_KEEP_COUNT}"

    while getopts "p:r:k:h" opt; do
        case "${opt}" in
            p) prefix="${OPTARG}" ;;
            r) runtime="${OPTARG}" ;;
            k)
                if ! [[ "${OPTARG}" =~ ^[0-9]+$ ]]; then
                    log_error "Keep count must be a positive integer."
                    usage
                    exit 1
                fi
                keep_count="${OPTARG}"
                ;;
            h)
                usage
                exit 0
                ;;
            *)
                usage
                exit 1
                ;;
        esac
    done

    # Validate required parameters
    if [[ -z "${prefix}" ]]; then
        log_error "Container prefix (-p) is required."
        usage
        exit 1
    fi

    if [[ -z "${runtime}" ]]; then
        log_error "Container runtime (-r) is required."
        usage
        exit 1
    fi

    # Restrict runtime to expected binaries (optional, but good for safety)
    if [[ "${runtime}" != "docker" && "${runtime}" != "podman" ]]; then
        log_error "Invalid runtime '${runtime}'. Expected 'docker' or 'podman'."
        usage
        exit 1
    fi

    # Verify the chosen runtime is installed and accessible
    if ! command -v "${runtime}" &> /dev/null; then
        log_error "The specified runtime '${runtime}' is not installed or not in PATH."
        exit 1
    fi

    cleanup_containers "${prefix}" "${keep_count}" "${runtime}"
}

main "$@"
