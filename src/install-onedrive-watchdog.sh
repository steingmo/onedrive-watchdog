#!/bin/sh
# Installs a watchdog that restarts OneDrive within 60s if it stops running.
# Usage:  sh install-onedrive-watchdog.sh            (install)
#         sh install-onedrive-watchdog.sh uninstall  (remove)
set -e
LABEL=local.onedrive-watchdog
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true

if [ "$1" = "uninstall" ]; then
  rm -f "$PLIST"
  echo "OneDrive watchdog removed."
  exit 0
fi

mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>local.onedrive-watchdog</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/sh</string><string>-c</string>
    <string>pgrep -xq -U "$(id -u)" OneDrive || { echo "$(date) OneDrive not running, restarting"; open -g -a OneDrive; }</string>
  </array>
  <key>StartInterval</key><integer>60</integer>
  <key>RunAtLoad</key><true/>
  <key>StandardOutPath</key><string>/tmp/onedrive-watchdog.log</string>
</dict>
</plist>
EOF
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "OneDrive watchdog installed. Log: /tmp/onedrive-watchdog.log"
