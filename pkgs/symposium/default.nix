{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
# TODO: migrate to finalAttrs pattern (modern nixpkgs style) when upgrading all pkgs
rustPlatform.buildRustPackage rec {
  pname = "symposium-acp-agent";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "symposium-dev";
    repo = "symposium";
    tag = "symposium-acp-agent-v${version}";
    hash = "sha256-cjF8bzdQRDqanNt2gxbzPG5o5hQEy7i3NnRD/wW4DCk=";
  };

  cargoHash = "sha256-gI5j2aXYlayWMh+An/EmqOqfnhOSCltutzmOjVrajfw=";
  cargoBuildFlags = [
    "-p"
    "symposium-acp-agent"
  ];
  doCheck = false;

  meta = {
    description = "ACP proxy agent with composable mods for AI coding";
    homepage = "https://github.com/symposium-dev/symposium";
    license = lib.licenses.asl20;
    mainProgram = "symposium-acp-agent";
  };
}
