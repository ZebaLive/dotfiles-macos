#!/bin/bash

# Script to exclude common development folders from Spotlight indexing
# This helps reduce mdworker_shared CPU usage

# Common folders to exclude from Spotlight indexing
EXCLUDE_PATTERNS=(
  "node_modules"
  "vendor"
  ".venv"
  "venv"
  "__pycache__"
  ".pyenv"
  "env"
  ".tox"
  "dist"
  "build"
  ".gradle"
  ".m2"
  "target"
  ".next"
  ".nuxt"
  ".cache"
  ".pytest_cache"
  ".mypy_cache"
  "coverage"
  ".coverage"
  ".eggs"
  "*.egg-info"
  ".git"
  ".svn"
)

echo "🔍 Searching for folders to exclude from Spotlight..."
echo ""

total_found=0
total_excluded=0

# Only search in development directories (much faster!)
SEARCH_DIRS=(
  "$HOME/Development"
  "$HOME/dotfiles"
)

# Find which directories exist
ACTIVE_SEARCH_DIRS=()
for dir in "${SEARCH_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    ACTIVE_SEARCH_DIRS+=("$dir")
  fi
done

if [ ${#ACTIVE_SEARCH_DIRS[@]} -eq 0 ]; then
  echo "⚠️  No development directories found"
  echo "Searching entire home directory instead..."
  ACTIVE_SEARCH_DIRS=("$HOME")
fi

for pattern in "${EXCLUDE_PATTERNS[@]}"; do
  echo "Searching for: $pattern"
  
  # Find directories matching the pattern
  while IFS= read -r dir; do
    ((total_found++))
    
    # Create .metadata_never_index file to prevent indexing
    if [ ! -f "$dir/.metadata_never_index" ]; then
      if touch "$dir/.metadata_never_index" 2>/dev/null; then
        echo "  ✓ Excluded: $dir"
        ((total_excluded++))
      fi
    else
      echo "  ✓ Already excluded: $dir"
    fi
  done < <(find "${ACTIVE_SEARCH_DIRS[@]}" -type d -name "$pattern" 2>/dev/null)
done

echo ""
echo "✅ Done!"
echo "Processed $total_found folders"
echo "Newly excluded: $total_excluded folders"
echo ""
echo "Alternative methods:"
echo "1. Manually add folders via System Settings → Siri & Spotlight → Spotlight Privacy"
echo "2. Disable indexing for specific volumes: sudo mdutil -i off /Volumes/YourDrive"
echo "3. Check indexing status: mdutil -s /"
