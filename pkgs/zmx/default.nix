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
    aarch64-darwin = fetchurl {
      url = "https://zmx.sh/a/zmx-${version}-macos-aarch64.tar.gz";
      hash = "sha256-V9SYOm6n7VwEt4ebkNQ0zCAtwLY3ysgK59WuCbQesWA=";
    };
    x86_64-darwin = fetchurl {
      url = "https://zmx.sh/a/zmx-${version}-macos-x86_64.tar.gz";
      hash = "sha256-GunNG+i69eUaaci6kVZpip+DPgiRFmQoEbhaRE4mJ8c=";
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
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
