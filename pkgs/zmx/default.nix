{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.4.2";
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://zmx.sh/a/zmx-${version}-linux-x86_64.tar.gz";
      hash = "sha256-JSPSkAbo4NdoyA9APK0pROkNWMuj9oqRJ3sLgNDB8jc=";
    };
    aarch64-linux = fetchurl {
      url = "https://zmx.sh/a/zmx-${version}-linux-aarch64.tar.gz";
      hash = "sha256-k23OdKSosGJEBKtTldXp3ksNpyn4dJkSdzeF18bfHJo=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "zmx";
  inherit version;

  src =
    srcs.${stdenvNoCC.hostPlatform.system}
      or (throw "zmx: unsupported system ${stdenvNoCC.hostPlatform.system}");

  sourceRoot = ".";
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -Dm755 zmx $out/bin/zmx
  '';

  meta = {
    description = "Terminal session persistence using libghostty-vt";
    homepage = "https://github.com/neurosnap/zmx";
    license = lib.licenses.mit;
    mainProgram = "zmx";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
