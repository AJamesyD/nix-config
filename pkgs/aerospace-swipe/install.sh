# shellcheck shell=bash
# shellcheck disable=SC2086,SC2154
mkdir -p $out/Applications/AerospaceSwipe.app/Contents/{MacOS,Resources}

cp swipe $out/Applications/AerospaceSwipe.app/Contents/MacOS/AerospaceSwipe

cat >$out/Applications/AerospaceSwipe.app/Contents/Info.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>AerospaceSwipe</string>
  <key>CFBundleIdentifier</key>
  <string>com.acsandmann.swipe</string>
  <key>CFBundleName</key>
  <string>AerospaceSwipe</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSUIElement</key>
  <true/>
</dict>
</plist>
EOF

echo "APPL????" >$out/Applications/AerospaceSwipe.app/Contents/PkgInfo

mkdir -p $out/share/aerospace-swipe
cat >$out/share/aerospace-swipe/entitlements.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>com.apple.security.accessibility</key>
  <true/>
</dict>
</plist>
EOF

mkdir -p $out/bin
ln -s $out/Applications/AerospaceSwipe.app/Contents/MacOS/AerospaceSwipe $out/bin/aerospace-swipe
