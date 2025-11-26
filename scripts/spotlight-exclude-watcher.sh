#!/bin/bash

# Spotlight Exclude Watcher
# Monitors development directories for new folders and auto-excludes them
# Uses macOS FSEvents API (via fswatch) for efficient, event-driven monitoring

# Common development directories to watch (add yours here)
WATCH_DIRS=(
  "$HOME/Development"
  "$HOME/Projects"
  "$HOME/Code"
  "$HOME/dev"
  "$HOME/workspace"
)

EXCLUDE_PATTERNS="node_modules|vendor|\.venv|venv|__pycache__|\.pyenv|env|\.tox|dist|build|\.gradle|\.m2|target|\.next|\.nuxt|\.cache|\.pytest_cache|\.mypy_cache|coverage|\.coverage|\.eggs|.*\.egg-info"

echo "🔍 Spotlight Auto-Exclude Watcher Started"
echo "Monitoring directories for: $EXCLUDE_PATTERNS"
echo ""

# Use fswatch (install with: brew install fswatch)
if ! command -v fswatch &> /dev/null; then
    echo "❌ fswatch not found. Installing..."
    brew install fswatch
    exit 1
fi

# Find which watch directories actually exist
ACTIVE_DIRS=()
for dir in "${WATCH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        ACTIVE_DIRS+=("$dir")
        echo "📂 Watching: $dir"
    fi
done

if [ ${#ACTIVE_DIRS[@]} -eq 0 ]; then
    echo "⚠️  No development directories found to watch"
    echo "Create one of: ${WATCH_DIRS[*]}"
    exit 0
fi

echo ""
echo "Waiting for new folders..."
echo ""

# Watch only development directories (much more efficient than watching all of ~/)
# -r = recursive, -e = exclude all, -i = include only patterns, --event Created = only creation events
fswatch -r -e ".*" -i "/$EXCLUDE_PATTERNS$" --event Created "${ACTIVE_DIRS[@]}" 2>/dev/null | while read -r dir; do
    if [ -d "$dir" ]; then
        folder_name=$(basename "$dir")
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 📁 Detected: $folder_name"
        
        if touch "$dir/.metadata_never_index" 2>/dev/null; then
            echo "                           ✅ Excluded from Spotlight"
        else
            echo "                           ⚠️  Failed to exclude (check permissions)"
        fi
    fi
done
