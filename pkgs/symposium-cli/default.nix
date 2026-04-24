{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.2.1";
  sources = {
    aarch64-darwin = fetchurl {
      url = "https://github.com/symposium-dev/symposium/releases/download/symposium-v${version}/cargo-agents-aarch64-apple-darwin.tar.gz";
      hash = "sha256-n84YzvrZnVvUM9UKTJu8gummMln/JCL30TJajMoI1wk=";
    };
    aarch64-linux = fetchurl {
      url = "https://github.com/symposium-dev/symposium/releases/download/symposium-v${version}/cargo-agents-aarch64-unknown-linux-musl.tar.gz";
      hash = "sha256-wQOd7ZmB7GW+sN9nc7RZbSfZxSG0uXfSQa5ln4aLYqE=";
    };
    x86_64-linux = fetchurl {
      url = "https://github.com/symposium-dev/symposium/releases/download/symposium-v${version}/cargo-agents-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-5oOX0RkVO6t3pLDSLVS1P9193pghVoBkt65m9MFgLYc=";
    };
  };
in
stdenvNoCC.mkDerivation {
  pname = "symposium-cli";
  inherit version;

  src =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "unsupported system: ${stdenvNoCC.hostPlatform.system}");

  sourceRoot = ".";

  installPhase = ''
    install -Dm755 cargo-agents $out/bin/cargo-agents
  '';

  meta = {
    description = "Symposium CLI for AI coding agents";
    homepage = "https://github.com/symposium-dev/symposium";
    license = lib.licenses.asl20;
    mainProgram = "cargo-agents";
  };
}
