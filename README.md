# OneDrive Watchdog

OneDrive on macOS sometimes crashes without you noticing. OneDrive Watchdog checks every
60 seconds that OneDrive is running and starts it again if it isn't.

## Install

**Homebrew** (turns the watchdog on right away):

```sh
brew install --cask steingmo/tap/onedrive-watchdog
```

**Manually:** download the zip from [Releases](https://github.com/steingmo/onedrive-watchdog/releases),
open **OneDrive Watchdog** and click **Install**. No admin password needed.

## Uninstall

`brew uninstall --cask onedrive-watchdog`, or open the app and click **Uninstall**.

## How it works

It installs a per-user LaunchAgent (`~/Library/LaunchAgents/local.onedrive-watchdog.plist`)
that runs `pgrep OneDrive || open -a OneDrive` every minute. Restarts are logged to
`/tmp/onedrive-watchdog.log`.

## Releasing

```sh
./release.sh 1.0.1   # build, sign, notarize, GitHub release, update the Homebrew cask
```
