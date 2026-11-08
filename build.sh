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
# Each CI build gets a higher version so Feather can see there's an update.
BUILD_NUMBER="${BUILD_NUMBER:-1}"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0.${BUILD_NUMBER}" "$APP/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" "$APP/Info.plist"
echo "Version 1.0.${BUILD_NUMBER} (${BUILD_NUMBER})"

# Build-environment keys Xcode normally adds; iOS services (incl. widget discovery) read them.
SDK_VERSION="$(xcrun --sdk iphoneos --show-sdk-version)"
SDK_BUILD="$(xcrun --sdk iphoneos --show-sdk-build-version)"
XCODE_VERSION="$(xcodebuild -version | awk '/^Xcode/{print $2}')"
XCODE_BUILD="$(xcodebuild -version | awk '/Build version/{print $3}')"
DT_XCODE="$(echo "$XCODE_VERSION" | awk -F. '{printf "%d%d%d", $1, ($2==""?0:$2), ($3==""?0:$3)}')"
MAC_BUILD="$(sw_vers -buildVersion)"
add_dt_keys() {
  local plist="$1"
  for kv in "DTSDKName:iphoneos${SDK_VERSION}" "DTPlatformVersion:${SDK_VERSION}" \
            "DTSDKBuild:${SDK_BUILD}" "DTPlatformBuild:${SDK_BUILD}" "DTXcode:${DT_XCODE}" \
            "DTXcodeBuild:${XCODE_BUILD}" "DTCompiler:com.apple.compilers.llvm.clang.1_0" \
            "BuildMachineOSBuild:${MAC_BUILD}"; do
    local key="${kv%%:*}" val="${kv#*:}"
    /usr/libexec/PlistBuddy -c "Delete :${key}" "$plist" 2>/dev/null || true
    /usr/libexec/PlistBuddy -c "Add :${key} string ${val}" "$plist"
  done
}
add_dt_keys "$APP/Info.plist"
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

echo "==> Building home screen widget extension"
WIDGET="$APP/PlugIns/TeyvatWidget.appex"
mkdir -p "$WIDGET"
xcrun --sdk iphoneos swiftc \
  -sdk "$SDK" \
  -target "arm64-apple-ios${MIN_IOS}" \
  -parse-as-library \
  -application-extension \
  -O -whole-module-optimization \
  -module-name TeyvatWidget \
  -Xlinker -application_extension \
  "$ROOT"/Widget/*.swift \
  -o "$WIDGET/TeyvatWidget"
cp "$ROOT/Widget/Info.plist" "$WIDGET/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString 1.0.${BUILD_NUMBER}" "$WIDGET/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_NUMBER}" "$WIDGET/Info.plist"
add_dt_keys "$WIDGET/Info.plist"

echo "==> Ad-hoc signing (Feather will re-sign with your certificate)"
codesign --force --sign - --timestamp=none --entitlements "$ROOT/Widget/Widget.entitlements" "$WIDGET" || true
codesign --force --sign - --timestamp=none --entitlements "$ROOT/Resources/App.entitlements" "$APP" || true

echo "==> Packaging IPA"
cd "$BUILD"
zip -qry GenshinTracker.ipa Payload
ls -lh "$BUILD/GenshinTracker.ipa"
echo "Done: $BUILD/GenshinTracker.ipa"
