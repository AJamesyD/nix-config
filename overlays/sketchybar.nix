# .app bundle wrapper: enables TCC to identify sketchybar by bundle ID
# (client_type=0) instead of nix store path (client_type=1). This means
# Accessibility permission survives nix rebuilds. Follows the same pattern
# that makes AeroSpace immune to TCC re-grants.
#
# TODO: re-enable popup patch once nixpkgs ships a cctools linker compatible
# with macOS 26 (Tahoe). The patch forces a local build which hits BPT trap.
# Tracked: https://github.com/NixOS/nixpkgs/issues/540303
# Patch bug: https://github.com/FelixKratz/SketchyBar/issues/742
# To re-enable: set enablePopupPatch = true
final: prev:
let
  enablePopupPatch = false;

  base =
    if enablePopupPatch then
      prev.sketchybar.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./patches/sketchybar-popup-all-displays.patch
        ];
      })
    else
      prev.sketchybar;
in
{
  sketchybar = final.runCommand "sketchybar-${base.version}" { } ''
    mkdir -p $out/bin
    ln -s ${base}/bin/* $out/bin/

    appdir="$out/Applications/SketchyBar.app/Contents"
    mkdir -p "$appdir/MacOS" "$appdir/Resources"

    # Copy the binary into the bundle (not symlink: codesign needs a real file)
    cp ${base}/bin/sketchybar "$appdir/MacOS/sketchybar"

    cat > "$appdir/Info.plist" << 'PLIST'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
      "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>CFBundleExecutable</key>
      <string>sketchybar</string>
      <key>CFBundleIdentifier</key>
      <string>com.local.sketchybar</string>
      <key>CFBundleName</key>
      <string>SketchyBar</string>
      <key>CFBundlePackageType</key>
      <string>APPL</string>
      <key>CFBundleShortVersionString</key>
      <string>${base.version}</string>
      <key>LSUIElement</key>
      <true/>
    </dict>
    </plist>
    PLIST

    echo -n "APPL????" > "$appdir/PkgInfo"
  '';
}
