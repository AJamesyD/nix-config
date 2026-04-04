{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rtk";
  version = "0.34.2";

  src = fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oBaF3BdF4h7meP7+8gtqBSgOFn0wQq08bOkygpn/ukg=";
  };

  cargoHash = "sha256-o12ZlfUEzo/h1HuoqOY3BcpdLL+M8hJW7sJL+3dkflU=";
  doCheck = false;

  meta = {
    description = "CLI output compression proxy for AI coding assistants";
    homepage = "https://github.com/rtk-ai/rtk";
    license = lib.licenses.mit;
    mainProgram = "rtk";
  };
})
