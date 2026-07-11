#!/usr/bin/env zsh

opencode-scrapesite() {
  if [[ -z "$1" ]]; then
    # Corrected a small typo in your original echo string ("scrapesice" -> "opencode-scrapesite")
    echo "Usage: opencode-scrapesite <URL>"
    return 1
  fi  

  local url="$1"
  local output_file="output_$(date +%s).html"

  echo "Fetching $url..."
  curl -L "$url" > "$output_file"

  if [[ $? -eq 0 ]]; then
    echo "Successfully saved to $output_file"
    echo "----------------------------------------"
    
    # Extract links (href attributes) using regex mapping from the saved file
    echo "=== Extracted Links ==="
    grep -oE 'href="https?://[^"]+"' "$output_file" | sed 's/href="//;s/"//'
    echo ""

    # Extract plain text content inside heading tags (H1, H2, H3) from the saved file
    echo "=== Page Headings ==="
    grep -oE '<h[1-3][^>]*>.*?</h[1-3]>' "$output_file" | sed -E 's/<[^>]*>//g'
    echo "----------------------------------------"
  else
    echo "Failed to fetch URL."
    return 1
  fi  
}
