# .app bundle wrapper for TCC stabilization (same pattern as sketchybar.nix)
final: prev: {
  jankyborders = final.runCommand "jankyborders-${prev.jankyborders.version}" { } ''
    mkdir -p $out/bin
    ln -s ${prev.jankyborders}/bin/* $out/bin/

    appdir="$out/Applications/JankyBorders.app/Contents"
    mkdir -p "$appdir/MacOS"

    cp ${prev.jankyborders}/bin/borders "$appdir/MacOS/borders"

    cat > "$appdir/Info.plist" << 'PLIST'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
      "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleExecutable</key>
      <string>borders</string>
      <key>CFBundleIdentifier</key>
      <string>com.local.jankyborders</string>
      <key>CFBundleName</key>
      <string>JankyBorders</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
      <key>LSUIElement</key>
      <true/>
    </dict>
    </plist>
    PLIST

    echo -n "APPL????" > "$appdir/PkgInfo"
  '';
}
