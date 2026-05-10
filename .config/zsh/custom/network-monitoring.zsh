#!/usr/bin/env zsh

# ==============================================================================
# PORT WATCHER MONITOR
# ==============================================================================
# Monitors a specific port for connection attempts, success, termination, 
# and prevents duplicate logging.
# ==============================================================================

# --- Configuration ---
TARGET_PORT="${1:-22}" # Default to SSH if no argument provided
LOG_FILE="/var/log/port_watch_${TARGET_PORT}.log"
UPDATE_INTERVAL="${2:-5}" # Check every N seconds (default 5s)
MAX_LOG_SIZE="${3:-50}"   # Max log file size in MB before rotation

# --- Functions ---

# Function to ensure log directory exists
ensure_dir() {
    local dir=$(dirname "$LOG_FILE")
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" 2>/dev/null
    fi
}

# Function to get a unique session ID for a connection
# We combine Timestamp + Source IP + Source Port to create a signature
get_connection_id() {
    local src_ip="$1"
    local src_port="$2"
    local ts=$(date +%s%N)
    echo "${ts}_${src_ip}_${src_port}"
}

# Function to check if an ID already exists in the log
is_duplicate() {
    local conn_id="$1"
    # Returns 0 (true) if found, 1 (false) otherwise
    grep -q "$conn_id" "$LOG_FILE" 2>/dev/null
}

# Function to write log entry safely
log_entry() {
    local level="$1"
    local conn_id="$2"
    local details="$3"
    
    # Prevent duplicate logging using ID
    if [[ $(is_duplicate "$conn_id") -eq 0 ]]; then
        # Append to log file with tabular format for readability
        printf "%s | %s | %s | %s\n" "$level" "$conn_id" "$(date '+%F %T')" "$details" >> "$LOG_FILE"
    fi
}

# Function to rotate log file if too large
rotate_log() {
    if [[ -f "$LOG_FILE" ]]; then
        local size_bytes=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
        local size_mb=$((size_bytes / 1024 / 1024))
        
        if (( size_mb >= MAX_LOG_SIZE )); then
            mv "$LOG_FILE" "${LOG_FILE}.$(date +%Y%m%d%H%M%S)"
            touch "$LOG_FILE"
            echo "[INFO] Log rotated."
        fi
    fi
}

# Main Monitoring Loop
main_loop() {
    local prev_state=""
    
    while true; do
        ensure_dir
        rotate_log

        # Fetch active connections on the specific port
        # ss output: Netid State Recv-Q Send-Q Local Address:Port  Peer Address:Port 
        # We filter for ESTAB (Established) and LISTEN (if you want to track open slots)
        # Usually we care about connections *to* the port.
        local connections=$(ss -tanp \
            'state,local,dst' \
            '$((sport == '"$TARGET_PORT"'))' \
            2>/dev/null)

        # Parse each line
        while IFS= read -r line; do
            # Skip header
            [[ "$line" =~ ^Netid ]] && continue
            
            # Extract fields
            # ss -tanp gives: state, local, dst
            local state=$(echo "$line" | awk '{print $2}')
            local local_addr=$(echo "$line" | awk '{print $5}')
            local dst_addr=$(echo "$line" | awk '{print $6}')
            
            # Extract IP and Port from Local Address
            local src_ip=$(echo "$local_addr" | cut -d: -f1)
            local src_port=$(echo "$local_addr" | cut -d: -f2)
            
            # Create Unique ID
            local conn_id=$(get_connection_id "$src_ip" "$src_port")

            # --- LOGIC PER STATE ---

            if [[ "$state" == "LISTEN" ]]; then
                # A server is waiting for connections
                : # Do nothing or log server status
                continue

            elif [[ "$state" == "ESTAB" ]]; then
                # SUCCESSFUL CONNECTION
                # Logic: Is this the first time we see this peer?
                if ! is_duplicate "$conn_id"; then
                    # NEW SUCCESSFUL CONNECTION
                    log_entry "SUCCESS" "$conn_id" "New connection established from $src_ip:$src_port to port $TARGET_PORT"
                else
                    # EXISTING SUCCESSFUL CONNECTION (Already logged)
                    # Optional: Log periodic updates or heartbeat
                fi

            elif [[ "$state" == "TIME-WAIT" ]]; then
                # Connection was recently terminated (ACK sent)
                if ! is_duplicate "$conn_id"; then
                    log_entry "TERMINATED" "$conn_id" "Connection terminated/closed by $src_ip:$src_port"
                fi
                # Note: Time-wait can persist for 60s+. You may want to debounce this if strict real-time is needed.

            elif [[ "$state" == "SYN-SENT" ]] || [[ "$state" == "SYN-RECV" ]]; then
                # HANDSHAKE IN PROGRESS
                # These indicate active attempts to connect (handshake not complete)
                if ! is_duplicate "$conn_id"; then
                    log_entry "ATTEMPT" "$conn_id" "Handshake detected (Syn) from $src_ip:$src_port"
                fi
            fi

            # --- SECURITY CHECK (Optional) ---
            # If the peer is not in the allowed list (not implemented here to keep script generic)
            
        done <<< "$connections"

        sleep "$UPDATE_INTERVAL"
    done
}

main_loop
