{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "aerospace-swipe";
  version = "0-unstable-2025-11-17";

  src = fetchFromGitHub {
    owner = "acsandmann";
    repo = "aerospace-swipe";
    rev = "976c3107f6ed9859149bdc130e3f8928f2ab6852";
    hash = "sha256-ARJfYiWXBCvXA5JlFl/s4VIQ9xuqBoU3gPfC8B2mkWI=";
  };

  buildPhase = ''
    $CC -std=c99 -O2 -fobjc-arc \
      -o swipe \
      src/aerospace.c src/yyjson.c src/haptic.c src/event_tap.m src/main.m \
      -framework CoreFoundation -framework IOKit \
      -F/System/Library/PrivateFrameworks -framework MultitouchSupport \
      -framework ApplicationServices -framework Cocoa \
      -ldl
  '';

  installPhase = ''
        mkdir -p $out/Applications/AerospaceSwipe.app/Contents/{MacOS,Resources}

        cp swipe $out/Applications/AerospaceSwipe.app/Contents/MacOS/AerospaceSwipe

        cat > $out/Applications/AerospaceSwipe.app/Contents/Info.plist << 'EOF'
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

        echo "APPL????" > $out/Applications/AerospaceSwipe.app/Contents/PkgInfo

        mkdir -p $out/share/aerospace-swipe
        cat > $out/share/aerospace-swipe/entitlements.plist << 'EOF'
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
  '';

  meta = {
    description = "Trackpad swipe gestures for AeroSpace workspace switching";
    homepage = "https://github.com/acsandmann/aerospace-swipe";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "aerospace-swipe";
  };
}
