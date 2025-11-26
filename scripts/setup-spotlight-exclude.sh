#!/bin/bash

# Setup Spotlight Auto-Exclude Service
# This installs a background service that watches for new development folders

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_FILE="$SCRIPT_DIR/com.user.spotlight-exclude-watcher.plist"
WATCHER_SCRIPT="$SCRIPT_DIR/spotlight-exclude-watcher.sh"
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
INSTALLED_PLIST="$LAUNCH_AGENTS_DIR/com.user.spotlight-exclude-watcher.plist"

echo "🔧 Setting up Spotlight auto-exclude service..."
echo ""

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo "📦 Installing fswatch..."
    if command -v brew &> /dev/null; then
        brew install fswatch
    else
        echo "❌ Homebrew not found. Please install fswatch manually:"
        echo "   brew install fswatch"
        exit 1
    fi
fi

# Make watcher script executable
chmod +x "$WATCHER_SCRIPT"

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$LAUNCH_AGENTS_DIR"

# Copy plist to LaunchAgents
cp "$PLIST_FILE" "$INSTALLED_PLIST"

# Unload if already running
launchctl unload "$INSTALLED_PLIST" 2>/dev/null

# Load the service
launchctl load "$INSTALLED_PLIST"

echo "✅ Service installed and started!"
echo ""
echo "The watcher will now automatically exclude new development folders."
echo ""
echo "Management commands:"
echo "  Status:  launchctl list | grep spotlight-exclude-watcher"
echo "  Stop:    launchctl unload $INSTALLED_PLIST"
echo "  Start:   launchctl load $INSTALLED_PLIST"
echo "  Logs:    tail -f /tmp/spotlight-exclude-watcher.log"
echo ""
echo "To uninstall:"
echo "  launchctl unload $INSTALLED_PLIST"
echo "  rm $INSTALLED_PLIST"
