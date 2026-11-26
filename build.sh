#!/bin/zsh
# Builds, signs, notarizes and zips "OneDrive Watchdog.app" into dist/.
# Usage: ./build.sh 1.0.0
set -euo pipefail
cd "$(dirname "$0")"

VERSION="${1:?usage: ./build.sh X.Y.Z}"
IDENTITY="2DD529998D73B5813460D3E600A1A71BEC48B9DA"   # Developer ID Application: Steingrím Ósá (85KQFDH4D6)
PROFILE="${NOTARY_PROFILE:-keytype-notary}"
APP="dist/OneDrive Watchdog.app"
ZIP="dist/OneDrive-Watchdog-$VERSION.zip"

rm -rf dist && mkdir dist
osacompile -o "$APP" src/main.applescript
install -m 755 src/install-onedrive-watchdog.sh "$APP/Contents/Resources/"
P="$APP/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string fo.nema.onedrive-watchdog" "$P"
/usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string $VERSION" "$P"
/usr/libexec/PlistBuddy -c "Add :CFBundleVersion string $VERSION" "$P"
xattr -cr "$APP"
codesign --force --options runtime --timestamp --sign "$IDENTITY" "$APP"
codesign --verify --strict "$APP"

ditto -c -k --keepParent "$APP" "$ZIP"
xcrun notarytool submit "$ZIP" --keychain-profile "$PROFILE" --wait
xcrun stapler staple "$APP"
rm "$ZIP" && ditto -c -k --keepParent "$APP" "$ZIP"
spctl -a -t exec "$APP"
echo "built $ZIP"
