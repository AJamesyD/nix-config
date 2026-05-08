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

  installPhase = builtins.readFile ./install.sh;

  meta = {
    description = "Trackpad swipe gestures for AeroSpace workspace switching";
    homepage = "https://github.com/acsandmann/aerospace-swipe";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "aerospace-swipe";
  };
}
