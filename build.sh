#!/bin/bash
# Builds an unsigned GenshinTracker.ipa (sign it with Feather / any sideloading tool).
# Requires macOS with Xcode installed. Used by .github/workflows/build.yml.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="$ROOT/build"
APP="$BUILD/Payload/GenshinTracker.app"
MIN_IOS="16.0"

rm -rf "$BUILD"
mkdir -p "$APP"

SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
echo "Using SDK: $SDK"
xcrun --sdk iphoneos swiftc --version

echo "==> Compiling Swift sources"
xcrun --sdk iphoneos swiftc \
  -sdk "$SDK" \
  -target "arm64-apple-ios${MIN_IOS}" \
  -parse-as-library \
  -O -whole-module-optimization \
  -module-name GenshinTracker \
  "$ROOT"/Sources/*.swift \
  -o "$APP/GenshinTracker"

echo "==> Copying resources"
cp "$ROOT/Resources/Info.plist" "$APP/Info.plist"
cp "$ROOT"/Resources/Icons/*.png "$APP/"

echo "==> Compiling asset catalog (app icon)"
xcrun actool "$ROOT/Resources/Assets.xcassets" \
  --compile "$APP" \
  --platform iphoneos \
  --minimum-deployment-target "$MIN_IOS" \
  --app-icon AppIcon \
  --target-device iphone --target-device ipad \
  --output-partial-info-plist "$BUILD/partial.plist" \
  --output-format human-readable-text || echo "actool failed; falling back to loose PNG icons"

printf 'APPL????' > "$APP/PkgInfo"

echo "==> Ad-hoc signing (Feather will re-sign with your certificate)"
codesign --force --sign - --timestamp=none "$APP" || true

echo "==> Packaging IPA"
cd "$BUILD"
zip -qry GenshinTracker.ipa Payload
ls -lh "$BUILD/GenshinTracker.ipa"
echo "Done: $BUILD/GenshinTracker.ipa"
