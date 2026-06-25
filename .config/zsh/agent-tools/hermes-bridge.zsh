#!/usr/bin/env zsh

# Name: hermes-bridge.zsh
# Description: Interface script optimized for Hermes Agent execution containment

# Strict error handling: crash if a pipeline step fails
set -o pipefail

# Hermes context tracking variables
export HERMES_EXECUTION_MODE="terminal-wrapper"
export HERMES_YOLO_MODE=${HERMES_YOLO:-0} # Tracks if --yolo flag was passed to bypass confirmation

# Ensure we have a command passed by the Hermes terminal toolset
if [[ $# -eq 0 ]]; then
    echo "JSON_ERROR: No system command received from Hermes context." >&2
    return 1
fi

# Reconstruct the tool command from arguments
HERMES_CMD="$@"

# Execute within a timed, monitored subshell to handle timeouts gracefully
# Hermes automatically flags long tracebacks, so stdout/stderr separation is vital
{
    eval "$HERMES_CMD"
} 2> >(while read -r line; do echo "[HERMES_STDERR] $line" >&2; done) \
  | while read -r line; do echo "[HERMES_STDOUT] $line"; done

# Capture true exit status of evaluated block
exit_code=$?

if [[ $exit_code -ne 0 ]]; then
    echo "[HERMES_STATUS] Command failed with exit code $exit_code" >&2
    return $exit_code
fi

return 0
