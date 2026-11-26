#!/bin/zsh
# Releases a new version end-to-end:
#   build + notarize, tag vX.Y.Z, GitHub release with the zip, update the Homebrew cask.
# Usage: ./release.sh 1.0.1
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:?usage: ./release.sh X.Y.Z}"
REPO="steingmo/onedrive-watchdog"
TAP_DIR="$HOME/Documents/homebrew-tap"

[[ -z "$(git status --porcelain)" ]] || { echo "error: uncommitted changes." >&2; exit 1; }
! git rev-parse "v$VERSION" >/dev/null 2>&1 || { echo "error: tag v$VERSION exists." >&2; exit 1; }

./build.sh "$VERSION"
ZIP="dist/OneDrive-Watchdog-$VERSION.zip"
SHA256="$(shasum -a 256 "$ZIP" | awk '{print $1}')"

git tag "v$VERSION"
git push origin main "v$VERSION"
gh release create "v$VERSION" "$ZIP" --repo "$REPO" --title "OneDrive Watchdog $VERSION" --generate-notes

git -C "$TAP_DIR" pull --quiet
cat > "$TAP_DIR/Casks/onedrive-watchdog.rb" <<CASK
cask "onedrive-watchdog" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/$REPO/releases/download/v#{version}/OneDrive-Watchdog-#{version}.zip"
  name "OneDrive Watchdog"
  desc "Restarts OneDrive automatically if it stops running"
  homepage "https://github.com/$REPO"

  app "OneDrive Watchdog.app"

  # Turn the watchdog on right away; no need to open the app.
  postflight do
    system_command "/bin/sh",
                   args: ["#{appdir}/OneDrive Watchdog.app/Contents/Resources/install-onedrive-watchdog.sh"]
  end

  uninstall script: {
    executable:   "/bin/sh",
    args:         ["#{appdir}/OneDrive Watchdog.app/Contents/Resources/install-onedrive-watchdog.sh", "uninstall"],
    must_succeed: false,
  }
end
CASK
git -C "$TAP_DIR" add Casks/onedrive-watchdog.rb
git -C "$TAP_DIR" commit -m "onedrive-watchdog $VERSION"
git -C "$TAP_DIR" push

echo "Released: https://github.com/$REPO/releases/tag/v$VERSION"
