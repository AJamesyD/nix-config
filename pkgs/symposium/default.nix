{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "2.0.1";
  sources = {
    aarch64-darwin = fetchurl {
      url = "https://github.com/symposium-dev/symposium/releases/download/symposium-acp-agent-v${version}/symposium-darwin-arm64.tar.gz";
      hash = "sha256-SjLJ6Uk8gTWitodd/oxmFNfxwEKEePiTUVGMB7FrJyI=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/symposium-dev/symposium/releases/download/symposium-acp-agent-v${version}/symposium-linux-arm64.tar.gz";
      hash = "sha256-kt+nmacdwjHxr2u8Zv77FwOPbbgEqI+epNIcYBfwX+o=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/symposium-dev/symposium/releases/download/symposium-acp-agent-v${version}/symposium-linux-x64.tar.gz";
      hash = "sha256-7DUVgVtUS3ctlyg//FLH7p3I9i5Zo+jxWg9VZUt+n7A=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "symposium-acp-agent";
  inherit version;

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "unsupported system: ${stdenvNoCC.hostPlatform.system}");

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 symposium-acp-agent $out/bin/symposium-acp-agent
  '';

  meta = {
    description = "ACP proxy agent with composable mods for AI coding";
    homepage = "https://github.com/symposium-dev/symposium";
    license = lib.licenses.asl20;
    mainProgram = "symposium-acp-agent";
  };
}
