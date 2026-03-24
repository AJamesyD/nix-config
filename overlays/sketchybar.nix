# .app bundle wrapper: enables TCC to identify sketchybar by bundle ID
# (client_type=0) instead of nix store path (client_type=1). This means
# Accessibility permission survives nix rebuilds. Follows the same pattern
# that makes AeroSpace immune to TCC re-grants.
# See /tmp/ai-research-nix-darwin-tcc-issues.md for full analysis.
#
# Uses runCommand (not overrideAttrs) so the upstream binary is fetched
# from cache.nixos.org. overrideAttrs changes the derivation hash,
# forcing a local source build that hangs under the nix darwin sandbox
# (private framework access: SkyLight, DisplayServices, MediaRemote).
#
# Patch: render popups on all displays, not just the focused one
# - https://github.com/FelixKratz/SketchyBar/issues/316
# - https://github.com/FelixKratz/SketchyBar/issues/742
final: prev:
let
  enablePopupPatch = true;

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
