{
  lib,
  stdenvNoCC,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
let
  version = "0.34.2";
  sources = {
    aarch64-darwin = fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-apple-darwin.tar.gz";
      hash = "sha256-3ZgtnLDYUv7XJLf1p+DyXWpmXuuUcLDK6/12B2s7m0E=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-aarch64-unknown-linux-gnu.tar.gz";
      hash = "sha256-/BaGNc9lcV2uXLTxHNdgRLTIJHAtUMMoBwt4qzH7bFE=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-QZs4IWyLEknMcjhtS7z+nngIveCvYxWcgmQ42lNPnlk=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "rtk";
  inherit version;

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "unsupported system: ${stdenvNoCC.hostPlatform.system}");

  sourceRoot = ".";

  # aarch64-linux binary is dynamically linked against glibc; autoPatchelfHook fixes the interpreter and rpath
  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  installPhase = ''
    install -Dm755 rtk $out/bin/rtk
  '';

  meta = {
    description = "CLI output compression proxy for AI coding assistants";
    homepage = "https://github.com/rtk-ai/rtk";
    license = lib.licenses.mit;
    mainProgram = "rtk";
  };
}
