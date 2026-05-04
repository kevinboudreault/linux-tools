#!/usr/bin/env zsh

# Script to clean up disk space

clean_disk() {
    LOG_DIR="/var/log"
    USER_CACHE="$HOME/.cache"
    LOGS_MAX_SIZE="100M"

    # Check for root privileges for system-wide cleaning
    if [[ $EUID -ne 0 ]]; then
       echo "Please run as root (sudo) to clean system logs and DNF cache."
       exit 1
    fi

    echo "--- Starting Disk Cleanup ---"

    # 1. Clear DNF Cache and Metadata
    echo "Cleaning DNF cache and removing orphaned packages..."
    dnf clean all
    dnf autoremove -y

    # 2. Vacuum Systemd Journals
    echo "Reducing systemd journal logs to $LOGS_MAX_SIZE..."
    journalctl --vacuum-size=$LOGS_MAX_SIZE

    # 3. Clean Flatpak (if installed)
    if command -v flatpak &> /dev/null; then
        echo "Removing unused Flatpak runtimes..."
        flatpak uninstall --unused -y
    fi

    # 4. Truncate System Logs
    echo "Truncating large log files in $LOG_DIR..."
    find "$LOG_DIR" -type f -name "*.log" -exec truncate -s 0 {} +

    # 5. Clear User Cache
    if [ -d "$USER_CACHE" ]; then
        echo "Cleaning user cache at $USER_CACHE..."
        rm -rf "$USER_CACHE"/*
    fi

    echo "--- Cleanup Complete ---"
    echo ""
    echo "--- Root Disk Space ---"
    df -h / | grep /
}