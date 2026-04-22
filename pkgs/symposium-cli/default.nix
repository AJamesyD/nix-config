{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "symposium-cli";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "symposium-dev";
    repo = "symposium";
    tag = "symposium-v${finalAttrs.version}";
    hash = "sha256-s0PYhsHnByHucNha86qdyNxFuHuV/QLZTea7pXkQUCA=";
  };

  cargoHash = "sha256-K81gw5Am+jhOrjsjL4yP/U6VRXtiH5kFLYvsb/bi/g0=";
  cargoBuildFlags = [
    "-p"
    "symposium"
  ];
  doCheck = false;

  meta = {
    description = "Symposium CLI for AI coding agents";
    homepage = "https://github.com/symposium-dev/symposium";
    license = lib.licenses.asl20;
    mainProgram = "cargo-agents";
  };
})
