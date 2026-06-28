#!/usr/bin/env zsh
# ==============================================================================
# Hermes Agent Zsh Productivity Helper (With Scraping Pipeline)
# ==============================================================================

# Global configuration paths
export HERMES_HELPER_DIR="${HOME}/.hermes"
export HERMES_SCRAPE_CACHE="${HERMES_HELPER_DIR}/scraped_pages"

# Ensure cache directories exist seamlessly
mkdir -p "$HERMES_SCRAPE_CACHE"

# 1. Web Scraping & Context Generation Pipeline
# Scrapes a URL, strips HTML noise, caches it, and prepares it for Hermes use
hermes_scrape() {
    local url=$1
    local custom_name=$2

    if [[ -z "$url" ]]; then
        echo "❌ Error: Please provide a target URL."
        echo "Usage: hermes_scrape <url> [optional_custom_filename]"
        return 1
    fi

    # Create a clean, safe filename from the URL or custom input
    local sanitized_name
    if [[ -n "$custom_name" ]]; then
        sanitized_name=$(echo "$custom_name" | tr -cd '[:alnum:]_-')
    else
        sanitized_name=$(echo "$url" | sed -E 's|https?://||; s|www\.||; s|[^[:alnum:]]|_|g' | cut -c1-50)
    fi

    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local output_file="${HERMES_SCRAPE_CACHE}/${sanitized_name}_${timestamp}.md"

    echo "🌐 Initiating target extraction: $url"
    
    # Check for available scraping CLI engines on the host system
    if command -v rdrview &> /dev/null; then
        # Uses rdrview (Firefox Reader View clone) if installed for clean Markdown/Text
        rdrview -M "$url" > "$output_file" 2>/dev/null
    elif command -v curl &> /dev/null && command -v pup &> /dev/null; then
        # Uses curl paired with HTML text extractor 'pup'
        curl -sL "$url" | pup 'body text{}' | sed '/^[[:space:]]*$/d' > "$output_file"
    elif command -v lynx &> /dev/null; then
        # Fallback to text-based web browser dump
        lynx -dump -nolist "$url" > "$output_file"
    elif command -v curl &> /dev/null; then
        # Bare fallback stripping script/style tags out natively
        curl -sL "$url" | sed -e 's/<script.[^>]*>.*<\/script>//g' -e 's/<style.[^>]*>.*<\/style>//g' -e 's/<[^>]*>//g' | sed '/^[[:space:]]*$/d' > "$output_file"
    else
        echo "❌ Error: No extraction utilities found. Please install 'curl', 'lynx', or 'rdrview'."
        return 1
    fi

    if [[ -s "$output_file" ]]; then
        echo "✅ Extraction Complete!"
        echo "📂 Cached at: $output_file"
        echo "💡 To inject this into Hermes later, run: ha \"Analyze this cached resource\" < $output_file"
    else
        echo "❌ Extraction failed or returned an empty payload."
        rm -f "$output_file"
        return 1
    fi
}

# 2. Direct Quick Ask (One-Shot Plaintext Pipeline)
ask_hermes() {
    if [[ -z "$1" ]]; then
        echo "❌ Error: Please provide a prompt."
        echo "Usage: ask_hermes \"Your prompt here\""
        return 1
    fi
    # Feeds standard input streams cleanly if piped
    if [[ ! -t 0 ]]; then
        hermes -z "$1"
    else
        hermes -z "$1"
    fi
}

# 3. Interactive Session Management
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

# 4. Fast Profile Switcher 
hermes_profile() {
    if [[ -z "$1" ]]; then
        echo "👤 Current active profile directory:"
        hermes profile list
        return 0
    fi
    echo "🎯 Launching Hermes with profile: $1"
    hermes --profile "$1"
}

# 5. Background Gateway Manager
hermes_gateway() {
    local action=$1
    local platform=$2
    
    if [[ -z "$action" ]]; then
        echo "🤖 Usage: hermes_gateway [start|stop|status] [platform]"
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

# 6. Skill & Plugin Quick Commands
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

# 7. Maintenance & Updates
hermes_upgrade() {
    echo "🔄 Updating Hermes Agent core engine..."
    hermes update --backup
    echo "✅ Update run completed."
}

# Scannable Productivity Aliases
alias hsc="hermes_scrape"          # hsc "https://hermes.org" "hermes_docs"
alias ha="ask_hermes"              # ha "Summarize this data" < ~/.hermes/scraped_pages/file.md
alias hs="hermes_sessions"         
alias hp="hermes_profile"          
alias hg="hermes_gateway"          
alias hk="hermes_skills"           
alias hup="hermes_upgrade"    
