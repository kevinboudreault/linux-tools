#!/bin/zsh
 
extract_env() {
    # Check if an argument is provided and if the file exists
    if [[ -z "$1" ]]; then
        echo "Usage: extract_env <filename>"
        return 1
    elif [[ ! -f "$1" ]]; then
        echo "Error: File '$1' not found."
        return 1
    fi

    # Determine destination: $2 if provided, otherwise standard output
    local dest="${2:-/dev/stdout}"

    # Extract keys using yq
    yq eval '.services[].environment[]' "$1" | cut -d '=' -f 1 | sort -u > "$dest"
}
