#!/usr/bin/env zsh

# Name: hermes-bridge.zsh
# Description: Interface script optimized for Hermes Agent execution containment

# Strict error handling: fail on undefined variables and pipeline errors
set -o errexit
set -o nounset
set -o pipefail

# Hermes context tracking variables
export HERMES_EXECUTION_MODE="terminal-wrapper"
export HERMES_YOLO_MODE="${HERMES_YOLO:-0}"

# Ensure a command was passed by the Hermes terminal toolset
if (( $# == 0 )); then
    echo "JSON_ERROR: No system command received from Hermes context." >&2 
    return 1
fi

# Define formatting filters to protect stdout/stderr separation
format_stdout() {
    while IFS= read -r line; do
        printf '[HERMES_STDOUT] %s\n' "$line"
    done
}

format_stderr() {
    while IFS= read -r line; do
        printf '[HERMES_STDERR] %s\n' "$line" >&2
    done
}

# Execute safely using zsh -c to preserve arguments and quoting structure
# Status is captured natively without pipe interference
zsh -c "$*" > >(format_stdout) 2> >(format_stderr)

# Capture true exit status of the evaluated block
exit_code=$?

if (( exit_code != 0 )); then
    printf '[HERMES_STATUS] Command failed with exit code %d\n' "$exit_code" >&2 
    return "$exit_code"
fi

return 0
