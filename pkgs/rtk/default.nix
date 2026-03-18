{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
# TODO: migrate to finalAttrs pattern (modern nixpkgs style) when upgrading all pkgs
rustPlatform.buildRustPackage rec {
  pname = "rtk";
  version = "0.30.1";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    tag = "v${version}";
    hash = "sha256-SIUtQ2y4O5F5ib8N9GKmsrd07CCtYco+Q3DInEd0uSw=";
  };

  cargoHash = "sha256-zJohVBlj6nFpfg6+E6Isnhxr9Tmhw5xW5tRF0HKmVXY=";
  doCheck = false;

  meta = {
    description = "CLI output compression proxy for AI coding assistants";
    homepage = "https://github.com/rtk-ai/rtk";
    license = lib.licenses.mit;
    mainProgram = "rtk";
  };
}
