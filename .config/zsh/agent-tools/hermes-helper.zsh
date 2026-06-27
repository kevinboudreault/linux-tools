#!/usr/bin/env zsh
# ==============================================================================
# Hermes Agent Zsh Productivity Helper
# ==============================================================================

# Global configuration paths
export HERMES_HELPER_DIR="${HOME}/.hermes"

# 1. Direct Quick Ask (One-Shot Plaintext Pipeline)
# Uses the streamlined 'hermes -z' flag for parent scripts / quick terminal inputs
ask_hermes() {
    if [[ -z "$1" ]]; then
        echo "❌ Error: Please provide a prompt."
        echo "Usage: ask_hermes \"Your prompt here\""
        return 1
    fi
    # If a file or stream is piped, pass it into the agent
    if [[ ! -t 0 ]]; then
        hermes -z "$1"
    else
        hermes -z "$1"
    fi
}

# 2. Interactive Session Management
# Quickly list, resume, or switch sessions
hermes_sessions() {
    local cmd=$1
    case "$cmd" in
        list|ls)
            echo "🔮 Active Hermes Sessions:"
            hermes session list
            ;;
        resume|r)
            if [[ -z "$2" ]]; then
                echo "🔄 Resuming most recent session..."
                hermes --continue
            else
                echo "🔄 Resuming session: $2"
                hermes --resume "$2"
            fi
            ;;
        *)
            echo "Usage: hermes_sessions [list|resume] [session_id_or_title]"
            ;;
    esac
}

# 3. Fast Profile Switcher 
# Allows operating isolated environments (e.g., dev vs. prod toolsets)
hermes_profile() {
    if [[ -z "$1" ]]; then
        echo "👤 Current active profile directory:"
        hermes profile list
        return 0
    fi
    echo "🎯 Launching Hermes with profile: $1"
    hermes --profile "$1"
}

# 4. Background Gateway Manager
# Spin up or monitor chat gateways (Telegram, Discord, Slack)
hermes_gateway() {
    local action=$1
    local platform=$2
    
    if [[ -z "$action" ]]; then
        echo "🤖 Usage: hermes_gateway [start|stop|status] [platform]"
        echo "Available platforms: telegram, discord, slack, whatsapp"
        return 1
    fi

    case "$action" in
        start)
            if [[ -z "$platform" ]]; then
                echo "❌ Please specify a platform (e.g., telegram, discord)"
                return 1
            fi
            echo "🚀 Starting Hermes Gateway for $platform in the background..."
            nohup hermes gateway start "$platform" > /tmp/hermes_gateway_${platform}.log 2>&1 &
            echo "✅ Gateway initiated. Logs at /tmp/hermes_gateway_${platform}.log"
            ;;
        status)
            echo "🔍 Checking background Hermes processes..."
            ps aux | grep "[h]ermes gateway" || echo "No active messaging gateways found."
            ;;
        stop)
            echo "🛑 Terminating background Hermes gateways..."
            pkill -f "hermes gateway start" && echo "✅ Gateways stopped." || echo "❌ No running gateways found."
            ;;
    esac
}

# 5. Skill & Plugin Quick Commands
# Easily add or audit community capabilities from standards like agentskills.io
hermes_skills() {
    local sub=$1
    case "$sub" in
        list|ls)
            hermes skills list
            ;;
        add)
            if [[ -z "$2" ]]; then
                echo "❌ Provide a skill name or git repository URI."
                return 1
            fi
            echo "⚡ Installing skill $2..."
            hermes skills install "$2"
            ;;
        *)
            echo "🧩 Usage: hermes_skills [list|add] [skill_identifier]"
            ;;
    esac
}

# 6. Maintenance & Updates
# Pulls down latest code changes and reinstalls environment dependencies
hermes_upgrade() {
    echo "🔄 Updating Hermes Agent core engine..."
    hermes update --backup
    echo "✅ Update run completed."
}

# Define Scannable Aliases for your .zshrc
alias ha="ask_hermes"              # ha "What is the status of my docker container?"
alias hs="hermes_sessions"         # hs list | hs resume [id]
alias hp="hermes_profile"          # hp dev-profile
alias hg="hermes_gateway"          # hg start discord | hg status
alias hk="hermes_skills"           # hk list
alias hup="hermes_upgrade"         # Core engine upgrader

