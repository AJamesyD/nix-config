# Fetch pre-compiled binary instead of building from source (~17min Rust compile).
final: prev:
let
  version = prev.mise.version;
  platformMap = {
    "aarch64-darwin" = {
      platform = "macos-arm64";
      hash = "sha256-rgwhUyd07aGYsjoip/++aE9ILAdKl2oT4PZkr4JV4q4=";
    };
    "aarch64-linux" = {
      platform = "linux-arm64";
      hash = "sha256-kCD3RTkxpoc9YM8gTVk169CGM7JfZ1sIIM0GhitLZFA=";
    };
    "x86_64-linux" = {
      platform = "linux-x64";
      hash = "sha256-vpLaOvsYDccbPOb8qq8vOTgSycUOmmTJy2cGzyjttIY=";
    };
  };
  platformInfo = platformMap.${prev.stdenv.hostPlatform.system};
in
{
  mise = prev.stdenvNoCC.mkDerivation {
    pname = "mise";
    inherit version;

    src = prev.fetchurl {
      url = "https://github.com/jdx/mise/releases/download/v${version}/mise-v${version}-${platformInfo.platform}.tar.gz";
      hash = platformInfo.hash;
    };

    sourceRoot = "mise";

    nativeBuildInputs = prev.lib.optionals prev.stdenv.hostPlatform.isLinux [
      prev.autoPatchelfHook
    ];

    buildInputs = prev.lib.optionals prev.stdenv.hostPlatform.isLinux [
      prev.stdenv.cc.cc.lib
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 bin/mise $out/bin/mise
      install -Dm644 man/man1/mise.1 $out/share/man/man1/mise.1
      runHook postInstall
    '';

    meta = prev.mise.meta;
  };
}
